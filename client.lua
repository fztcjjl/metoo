package.cpath = "skynet/luaclib/?.so;luaclib/?.so"
local service_path = "./lualib/?.lua;" .. "./common/?.lua;" .. "./global/?.lua;" .. "./?.lua"
package.path = "skynet/lualib/?.lua;skynet/service/?.lua;" .. service_path

local socket = require "clientsocket"
local crypt = require "crypt"
local protobuf = require "protobuf"
require "luaext"

protobuf.register_file("protocol/netmsg.pb")
protobuf.register_file("protocol/user.pb")

local LOGIN_HOST = "127.0.0.1"
local LOGIN_PORT = 5188

local GAME_HOST = "127.0.0.1"
local GAME_PORT = 5189

local gameserver = "game"

local fd

local secret

local USERNAME
local UID

local session = 0

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local last = ""

local function unpack_f(f)
	local function try_recv(fd, last)
		local result
		result, last = f(last)
		if result then
			return result, last
		end
		local r = socket.recv(fd)
		if not r then
			return nil, last
		end
		if r == "" then
			error "Server closed"
		end
		return f(last .. r)
	end

	return function()
		while true do
			local result
			result, last = try_recv(fd, last)
			if result then
				return result
			end
			socket.usleep(100)
		end
	end
end

local read_package = unpack_f(unpack_package)

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local function send_request(v)
	local size = #v + 4
	session = session + 1
	local package = string.pack(">I2", size)..v..string.pack(">I4", session)
	socket.send(fd, package)
	return v, session
end

local function recv_response(v)
	local size = #v - 5
	local content, ok, sess = string.unpack("c"..tostring(size).."B>I4", v)
	return ok ~=0 , content, sess
end

local CMD = {}

function CMD.help(  )
	local info = 
	[[
		"Usage":lua client.lua cmd arg[1] arg[2] ...
		- help
		- login token sdkid
	]]
	print(info)
end

local index = 0

function CMD.login(token, sdkid, noclose)
	assert(token and sdkid)

	-- 以下代码登录 loginserver
	fd = assert(socket.connect(LOGIN_HOST, LOGIN_PORT))

	local challenge = crypt.base64decode(read_package())	-- 读取用于握手验证的challenge

	local clientkey = crypt.randomkey()	-- 用于交换secret的clientkey
	send_package(crypt.base64encode(crypt.dhexchange(clientkey)))
	local serverkey = crypt.base64decode(read_package())	-- 读取serverkey
	secret = crypt.dhsecret(serverkey, clientkey)		-- 计算私钥

	print("sceret is ", crypt.hexencode(secret))

	local hmac = crypt.hmac64(challenge, secret)
	send_package(crypt.base64encode(hmac))		-- 回应服务器第一步握手的挑战码，确认握手正常

	token = string.format("%s:%s:%s", gameserver, token, sdkid)
	local etoken = crypt.desencode(secret, token)
	send_package(crypt.base64encode(etoken))

	local result = read_package()
	local code = tonumber(string.sub(result, 1, 3))
	assert(code == 200)
	socket.close(fd)	-- 认证成功，断开与登录服务器的连接

	local user = crypt.base64decode(string.sub(result, 4,#result))		-- base64(uid:subid)
	local result = string.split(user, ":")
	UID = tonumber(result[1])

	print(string.format("login ok, user %s, uid %d", user, UID))

	-- 以下代码与游戏服务器握手
	fd = assert(socket.connect(GAME_HOST, GAME_PORT))
	index = index + 1
	local handshake = string.format("%s@%s#%s:%d",
		crypt.base64encode(result[1]),
		crypt.base64encode(gameserver),
		crypt.base64encode(result[2]),
		index)
	print("handshake=%s", handshake)
	local hmac = crypt.hmac_hash(secret, handshake)

	send_package(handshake .. ":" .. crypt.base64encode(hmac))

	result = read_package()
	code = tonumber(string.sub(result, 1, 3))
	assert(code == 200)

	if not noclose then
		socket.close(fd)
	end

	print("handshake ok")
end

local function encode(name, data)
	local payload = protobuf.encode(name, data)
	local netmsg = { name = name, payload = payload }
	local pack = protobuf.encode("netmsg.NetMsg", netmsg)
	return pack
end

local function decode(data)
	local netmsg = protobuf.decode("netmsg.NetMsg", data)

	return netmsg
end

function CMD.roleinit(token, sdkid, name)
	CMD.login(token, sdkid, true)

	local data = { name = name }
	send_request(encode("user.RoleInitRequest", data))
	local ok, msg, sess = recv_response(read_package())
	msg = decode(msg)
	if msg then
		print("role init succ")
	end
end

function CMD.rolerename(token, sdkid, name)
	CMD.login(token, sdkid, true)

	local data = { name = name }
	send_request(encode("user.RoleRenameRequest", data))
	local ok, msg, sess = recv_response(read_package())
	msg = decode(msg)
	if msg then
		print("role rename succ")
	end
end

function CMD.userinfo(token, sdkid)
	CMD.login(token, sdkid, true)

	send_request(encode("user.UserInfoRequest", {}))
	local ok, msg, sess = recv_response(read_package())
	msg = decode(msg)
	if msg then
		print("userinfo succ")
	end
end

local function start(cmd, ...)
	if not cmd or cmd == "" then
		cmd = "help"
	end
	local f = assert(CMD[cmd], cmd .. " not found")
	f(...)
end

local args = { ... }

start(table.unpack(args))
