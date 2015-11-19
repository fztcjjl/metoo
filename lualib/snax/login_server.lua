-- 该模块以snax.loginserver为模板修改而来
local skynet = require "skynet"
require "skynet.manager"
local socket = require "socket"
local crypt = require "crypt"
local table = table
local string = string
local assert = assert

--[[

Protocol:

	line (\n) based text protocol

	1. Server->Client : base64(8bytes random challenge)
	2. Client->Server : base64(8bytes handshake client key)
	3. Server: Gen a 8bytes handshake server key
	4. Server->Client : base64(DH-Exchange(server key))
	5. Server/Client secret := DH-Secret(client key/server key)
	6. Client->Server : base64(HMAC(challenge, secret))
	7. Client->Server : DES(secret, base64(token))
	8. Server : call auth_handler(token) -> server, uid (A user defined method)
	9. Server : call login_handler(server, uid, secret) ->subid (A user defined method)
	10. Server->Client : 200 base64(subid)

Error Code:
	400 Bad Request . challenge failed
	401 Unauthorized . unauthorized by auth_handler
	403 Forbidden . login_handler failed
	406 Not Acceptable . already in login (disallow multi login)

Success:
	200 base64(uid:subid)
]]

local socket_error = {}

local function assert_socket(service, v, fd)
	if v then
		return v
	else
		LOG_ERROR(string.format("%s failed: socket (fd = %d) closed", service, fd))
		error(socket_error)
	end
end

local function write(service, fd, text)
	local sz = #text
	local buf = string.char(sz >> 8) .. string.char(sz & 0xff) .. text
	assert_socket(service, socket.write(fd, buf), fd)
end

local function read(service, fd)
	local ret = assert_socket(service, socket.read(fd, 2), fd)
	local sz = (string.byte(ret) << 8) + string.byte(ret, 2)
	assert(sz > 0, "error size " .. sz)

	return socket.read(fd, sz)
end

local function launch_slave(auth_handler)
	local function auth(fd, addr)
		LOG_INFO(string.format("connect from %s (fd = %d)", addr, fd))
		socket.start(fd)

		-- set socket buffer limit (8K)
		-- If the attacker send large package, close the socket
		socket.limit(fd, 8192)

		local challenge = crypt.randomkey()
		LOG_INFO(string.format("challenge is %s", crypt.base64encode(challenge)))
		write("auth", fd, crypt.base64encode(challenge))

		local handshake = read("auth", fd)
		local clientkey = crypt.base64decode(handshake)
		if #clientkey ~= 8 then
			LOG_ERROR("Invalid client key")
			error "Invalid client key"
		end
		local serverkey = crypt.randomkey()
		write("auth", fd, crypt.base64encode(crypt.dhexchange(serverkey)))

		local secret = crypt.dhsecret(clientkey, serverkey)

		local response = read("auth", fd)
		local hmac = crypt.hmac64(challenge, secret)

		if hmac ~= crypt.base64decode(response) then
			write("auth", fd, "400 Bad Request\n")
			LOG_ERROR("challenge failed")
			error "challenge failed"
		end

		local etoken = read("auth", fd)

		local token = crypt.desdecode(secret, crypt.base64decode(etoken))

		local ok, server, uid = pcall(auth_handler, token)

		return ok, server, uid, secret
	end

	local function ret_pack(fd, ok, err, ...)
		socket.abandon(fd)
		if ok then
			skynet.ret(skynet.pack(err, ...))
		else
			if err == socket_error then
				skynet.ret(skynet.pack(nil, "socket error"))
			else
				skynet.ret(skynet.pack(false, err))
			end
		end
	end

	skynet.dispatch("lua", function(_,_,fd,...)
		if type(fd) ~= "number" then
			skynet.ret(skynet.pack(false, "invalid fd type"))
		else
			ret_pack(fd,pcall(auth, fd, ...))
		end
	end)

end

local user_login = {}	-- key:uid value:true 表示玩家登录记录

local function accept(conf, s, fd, addr)
	-- call slave auth
	-- 调用login slave来进行认证，并且会暂时接管fd
	local ok, server, uid, secret = skynet.call(s, "lua",  fd, addr)
	socket.start(fd)	--重新接管fd

	-- 认证失败
	if not ok then
		if ok ~= nil then
			LOG_DEBUG("401 Unauthorized")
			write("response 401", fd, "401 Unauthorized")
		end
		error(server)
	end

	-- 一个用户在走登录流程时，禁止同一用户在别处登录
	if not conf.multilogin then
		if user_login[uid] then
			write("response 406", fd, "406 Not Acceptable")
			LOG_ERROR("406 Not Acceptable uid=%d", uid)
			error(string.format("User %s is already login", uid))
		end

		user_login[uid] = true
	end
	-- 回调登录服务器login_hander
	local ok, err = pcall(conf.login_handler, server, uid, secret)
	-- unlock login
	user_login[uid] = nil	-- 登录流程走完，解除登录限制

	if ok then
		err = err or ""
		write("response 200", fd, "200 "..crypt.base64encode(uid .. ":" .. err))
	else
		LOG_DEBUG("403 Forbidden uid=%d", uid)
		write("response 403", fd, "403 Forbidden")
		error(err)
	end
end

local function launch_master(conf)
	local instance = conf.instance or 8
	assert(instance > 0)
	local host = conf.host or "0.0.0.0"
	local port = assert(tonumber(conf.port))
	local slave = {}
	local balance = 1

	skynet.dispatch("lua", function(_,source,command, ...)
		skynet.ret(skynet.pack(conf.command_handler(command, ...)))
	end)

	--启动若干个login slave
	for i=1,instance do
		table.insert(slave, skynet.newservice(SERVICE_NAME))
	end

	skynet.error(string.format("login server listen at : %s %d", host, port))
	local id = socket.listen(host, port)
	socket.start(id , function(fd, addr)
		--采用roundbin算法轮叫一个login slave来处理登录请求
		local s = slave[balance]
		balance = balance + 1
		if balance > #slave then
			balance = 1
		end
		local ok, err = pcall(accept, conf, s, fd, addr)
		if not ok then
			if err ~= socket_error then
				LOG_DEBUG(string.format("invalid client (fd = %d) error = %s", fd, err))
			end
			socket.start(fd)
		end
		socket.close(fd)
	end)
end

local function login(conf)
	local name = "." .. (conf.name or "login")
	skynet.start(function()
		local loginmaster = skynet.localname(name)	--查询loginmaster地址
		if loginmaster then
			local auth_handler = assert(conf.auth_handler)
			launch_master = nil
			conf = nil
			launch_slave(auth_handler)	--启动login slave
		else
			launch_slave = nil
			conf.auth_handler = nil
			assert(conf.login_handler)
			assert(conf.command_handler)
			skynet.register(name)
			launch_master(conf)		--启动login master
		end
	end)
end

return login
