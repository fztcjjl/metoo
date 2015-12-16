local skynet = require "skynet"
require "skynet.manager"
local gateserver = require "snax.gateserver"
local netpack = require "netpack"
local crypt = require "crypt"
local socketdriver = require "socketdriver"
local assert = assert
local b64encode = crypt.base64encode
local b64decode = crypt.base64decode

--[[

Protocol:

	All the number type is big-endian

	Shakehands (The first package)

	Client -> Server :

	base64(uid)@base64(server)#base64(subid):index:base64(hmac)

	Server -> Client

	XXX ErrorCode
		404 User Not Found
		403 Index Expired
		401 Unauthorized
		400 Bad Request
		200 OK

	Req-Resp

	Client -> Server : Request
		word size (Not include self)
		string content (size-4)
		dword session

	Server -> Client : Response
		word size (Not include self)
		string content (size-5)
		byte ok (1 is ok, 0 is error)
		dword session

API:
	server.userid(username)
		return uid, subid, server

	server.username(uid, subid, server)
		return username

	server.login(username, secret)
		update user secret

	server.logout(username)
		user logout

	server.ip(username)
		return ip when connection establish, or nil

	server.start(conf)
		start server

Supported skynet command:
	kick username (may used by loginserver)
	login username secret  (used by loginserver)
	logout username (used by agent)

Config for server.start:
	conf.expired_number : the number of the response message cached after sending out (default is 128)
	conf.login_handler(uid, secret) -> subid : the function when a new user login, alloc a subid for it. (may call by login server)
	conf.logout_handler(uid, subid) : the functon when a user logout. (may call by agent)
	conf.kick_handler(uid, subid) : the functon when a user logout. (may call by login server)
	conf.request_handler(username, session, msg) : the function when recv a new request.
	conf.register_handler(servername) : call when gate open
	conf.disconnect_handler(username) : call when a connection disconnect (afk)
]]

local server = {}

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local user_online = {}	-- username -> u
local handshake = {}	-- 需要握手的连接列表
local connection = {}	-- fd -> u

function server.userid(username)
	-- base64(uid)@base64(server)#base64(subid)
	local uid, servername, subid = username:match "([^@]*)@([^#]*)#(.*)"
	return b64decode(uid), b64decode(subid), b64decode(servername)
end

function server.username(uid, subid, servername)
	return string.format("%s@%s#%s", b64encode(uid), b64encode(servername), b64encode(tostring(subid)))
end

function server.logout(username)
	local u = user_online[username]
	user_online[username] = nil
	if u and u.fd then
		gateserver.closeclient(u.fd)
		connection[u.fd] = nil
	end
end

function server.login(username, secret)
	assert(user_online[username] == nil)
	user_online[username] = {
		secret = secret,
		version = 0,
		index = 0,
		username = username,
		response = {},	-- response cache
	}
end

function server.ip(username)
	local u = user_online[username]
	if u and u.fd then
		return u.ip
	end
end

function server.start(conf)
	local expired_number = conf.expired_number or 128

	local handler = {}

	local CMD = {
		login = assert(conf.login_handler),
		logout = assert(conf.logout_handler),
		kick = assert(conf.kick_handler),
		init = assert(conf.init_handler),		-- 主要用于初始化agent池
		get_agents = assert(conf.get_agents),
		get_agent = assert(conf.get_agent),
		is_online = assert(conf.is_online),
	}

	-- 内部命令处理
	function handler.command(cmd, source, ...)
		local f = assert(CMD[cmd])
		return f(...)
	end

	-- 网关服务器open（打开监听）回调
	function handler.open(source, gateconf)
		local servername = assert(gateconf.servername)
		return conf.register_handler(servername)
	end

	-- 新连接到来回调
	function handler.connect(fd, addr)
		handshake[fd] = addr
		gateserver.openclient(fd)
	end

	-- 连接断开回调
	function handler.disconnect(fd)
		handshake[fd] = nil
		local c = connection[fd]
		if c then
			c.fd = nil
			connection[fd] = nil
			if conf.disconnect_handler then
				conf.disconnect_handler(c.username)
			end
		end
	end

	-- socket发生错误时回调
	handler.error = handler.disconnect

	local auth_handler = conf.auth_handler
	local online_handler = conf.online_handler

	-- atomic , no yield
	local function do_auth(fd, message, addr)
		local username, index, hmac = string.match(message, "([^:]*):([^:]*):([^:]*)")
		local u = user_online[username]
		if u == nil then
			return "404 User Not Found"
		end
		local idx = assert(tonumber(index))
		hmac = b64decode(hmac)

		if idx <= u.version then
			return "403 Index Expired"
		end

		local text = string.format("%s:%s", username, index)
		local v = crypt.hmac_hash(u.secret, text)	-- equivalent to crypt.hmac64(crypt.hashkey(text), u.secret)
		if v ~= hmac then
			return "401 Unauthorized"
		end

		u.version = idx
		u.fd = fd
		u.ip = addr
		connection[fd] = u

		auth_handler(username, fd)
	end

	local function auth(fd, addr, msg, sz)
		local message = netpack.tostring(msg, sz)
		local ok, result = pcall(do_auth, fd, message, addr)
		if not ok then
			skynet.error(result)
			result = "400 Bad Request"
		end

		local close = result ~= nil

		if result == nil then
			result = "200 OK"
		end

		socketdriver.send(fd, netpack.pack(result))

		if close then
			gateserver.closeclient(fd)
		else
			
			local username = string.match(message, "([^:]*):([^:]*):([^:]*)")
			
			local uid = server.userid(username)
			uid = tonumber(uid)
			online_handler(uid, fd)
		end
	end

	local request_handler = assert(conf.request_handler)
	
	local function do_request(fd, message)
		local u = assert(connection[fd], "invalid fd")
		local session = string.unpack(">I4", message, -4)
		message = message:sub(1,-5)
		pcall(conf.request_handler, u.username, message)
	end

	local function request(fd, msg, sz)
		local message = netpack.tostring(msg, sz)
		local ok, err = pcall(do_request, fd, message)
		-- not atomic, may yield
		if not ok then
			skynet.error(string.format("Invalid package %s : %s", err, message))
			if connection[fd] then
				gateserver.closeclient(fd)
			end
		end
	end

	-- socket消息到来时回调，新连接的第一条消息是握手消息
	function handler.message(fd, msg, sz)
		local addr = handshake[fd]
		if addr then
			auth(fd,addr,msg,sz)
			handshake[fd] = nil
		else
			request(fd, msg, sz)
		end
	end

	return gateserver.start(handler)
end

return server
