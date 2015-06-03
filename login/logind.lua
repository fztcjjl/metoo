local login = require "snax.login_server"
local crypt = require "crypt"
local skynet = require "skynet"
local snax = require "snax"
local cluster = require "cluster"

local server = {
	host = "0.0.0.0",
	port = tonumber(skynet.getenv("port")),
	multilogin = false,	-- disallow multilogin
	name = "login_master",
	instance = 8,
}

local user_online = {}	-- 记录玩家所登录的服务器

local account_dc

local function register(token, sdkid)
	--local uid = do_redis({ "incr", "d_account:id" })
	local uid = account_dc.req.get_nextid()
	if uid < 1 then
		LOG_DEBUG("register account get nextid failed")
		return
	end

	local row = { id = uid, pid = token, sdkid = sdkid }
	local ret = account_dc.req.add(row)

	if not ret then
		LOG_DEBUG("register account failed")
		return
	end

	LOG_INFO("register account succ uid=%d", uid)
	return uid
end

local function auth(token, sdkid)
	if not account_dc then
		account_dc = snax.uniqueservice("accountdc")
	end

	local account = account_dc.req.get(sdkid, token)

	local uid
	if table.empty(account) then
		uid = register(token, sdkid)
	else
		uid = account.id
	end

	return uid
end

function server.auth_handler(args)
	local ret = string.split(args, ":")
	assert(#ret == 3)
	local server = ret[1]
	local token = ret[2]
	local sdkid = tonumber(ret[3])

	LOG_INFO("auth_handler is performing server=%s token=%s sdkid=%d", server, token, sdkid)
	local uid = auth(token, sdkid)
	if not uid then
		error("auth failed")
	end
	return server, uid
end

-- 认证成功后，回调此函数，登录游戏服务器
function server.login_handler(server, uid, secret)
	LOG_INFO(string.format("%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret)))
	-- only one can login, because disallow multilogin
	local last = user_online[uid]
	-- 如果该用户已经在某个服务器上登录了，先踢下线
	if last then
		LOG_INFO(string.format("call gameserver %s to kick uid=%d subid=%d ...", last.server, uid, last.subid))
		local ok = pcall(cluster.call, last.server, "gated", "kick", uid, last.subid)
		if not ok then
			user_online[uid] = nil
		end
	end

	-- login_handler会被并发，可能同一用户在另一处中又登录了，所以再次确认是否登录
	if user_online[uid] then
		error(string.format("user %s is already online", uid))
	end

	-- 登录游戏服务器
	LOG_INFO(string.format("uid=%d is logging to gameserver %s ...", uid, server))
	local ok, subid = pcall(cluster.call, server, "gated", "login", uid, secret)
	if not ok then
		error("login gameserver error")
	end
	LOG_INFO(string.format("uid=%d logged on gameserver %s subid=%d ...", uid, server, subid))
	user_online[uid] = { subid = subid, server = server }
	return subid
end

local CMD = {}

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		LOG_INFO(string.format("%d@%s#%d is logout", uid, u.server, subid))
		user_online[uid] = nil
	end
end

function server.command_handler(command, source, ...)
	local f = assert(CMD[command])
	return f(source, ...)
end

login(server)	-- 启动登录服务器
