local skynet = require "skynet"
local queue = require "skynet.queue"
local snax = require "snax"
local netpack = require "netpack"
local profile = require "profile"
local protobuf = require "protobuf"

local cs = queue()
local UID
local SUB_ID
local SECRET
local user_dc
local afktime = 0

--用于统计执行信息
-----------------------------------bench begin-------------------
local ti = {}
setmetatable(ti, { __mode = "k" })

local gate		-- 游戏服务器gate地址

local CMD = {}

-- 玩家登录游服后调用
function CMD.login(source, uid, subid, secret)
	-- you may use secret to make a encrypted data stream
	LOG_INFO(string.format("%s is login", uid))
	gate = source
	UID = uid
	SUB_ID = subid
	SECRET = secret

	ti = {}
	afktime = 0
	-- you may load user data from database
end

-- 玩家登录游服，握手成功后调用
function CMD.auth(source, uid)
	LOG_INFO(string.format("%s is real login", uid))
	LOG_INFO("call dcmgr to load user data uid=%d", uid)
	skynet.call("dcmgr", "lua", "load", uid)	-- 加载玩家数据，重复加载是无害的
end

local function logout()
	if gate then
		skynet.call(gate, "lua", "logout", UID, SUB_ID)
	end

	gate = nil
	UID = nil
	SUB_ID = nil
	SECRET = nil

	ti = {}
	afktime = 0

	skynet.call("dcmgr", "lua", "unload", UID)	-- 卸载玩家数据
	--这里不退出agent服务，以便agent能复用
	--skynet.exit()	-- 玩家显示登出，需要退出agent服务
end

function CMD.logout(source)
	-- NOTICE: The logout MAY be reentry
	skynet.error(string.format("%s is logout", UID))
	logout()
end

function CMD.afk(source)
	-- the connection is broken, but the user may back
	afktime = skynet.time()
	skynet.error(string.format("AFK"))
end

local function update_ti(name, usetime)
	if ti[name] then
		ti[name].count = ti[name].count + 1
		ti[name].time = ti[name].time + usetime
	else
		ti[name] = { count = 1, time = usetime }
	end
end

local function timing()
	return ti
end
-----------------------------------bench end---------------------


local function msg_unpack(msg, sz)
	local data = netpack.tostring(msg, sz, 0) --必须为0,否则这边会直接被free掉,会造成coredump
	local netmsg = protobuf.decode("netmsg.NetMsg", data)

	if not netmsg then
		LOG_ERROR("msg_unpack error")
		error("msg_unpack error")
	end
	
	return netmsg
end

local function msg_pack(data)
	local msg = protobuf.encode("netmsg.NetMsg", data)
	if not msg then
		LOG_ERROR("msg_pack error")
		error("msg_pack error")
	end
	return msg
end

local function format_errmsg(errno, errmsg)
	local err = {}
	err.code = errno or 0
	err.desc = errmsg
	return err
end

local function msg_dispatch(netmsg)
	local begin = skynet.time()
	local uid = netmsg.head.uid
	if not uid or uid ~= UID then
		LOG_ERROR("uid is nil or uid=%d is not equal UID=%d", uid or 0, UID)
		error("Invalid uid")
	end

	assert(#netmsg.name > 0)
	if netmsg.name == "netmsg.LogoutRequest" then
		return logout()
	end

	profile.start()
	local name = netmsg.name
	LOG_INFO("calling to %s", name)
	local module, method = netmsg.name:match "([^.]*).(.*)"
	local data = {}
	local ok, obj = pcall(snax.uniqueservice, module)
	if not ok then
		LOG_ERROR(string.format("unknown module %s", module))
		data.errmsg = format_errmsg()
	else
		local ok, respname, payload, errno, errmsg = pcall(
			obj.req[method], {
				name = name,
				payload = netmsg.payload,
				uid = uid
			}
		)

		data.name = respname
		data.payload = payload
		data.errmsg = format_errmsg(errno, errmsg)
	end

	update_ti(netmsg.name, profile.stop())
	local result = msg_pack(data)
	LOG_DEBUG("dispatch over:%f, %s",skynet.time()-begin, name)

	return result
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,

	unpack = function (msg, sz)
		return msg_unpack(msg, sz)
	end,

	dispatch = function (_, _, netmsg)
		skynet.ret(msg_dispatch(netmsg))
	end
}

skynet.start(function()
	-- If you want to fork a work thread , you MUST do it in CMD.login
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
		skynet.retpack(cs(f, source, ...))
	end)

	protobuf.register_file("./protocol/netmsg.pb")
	user_dc = snax.uniqueservice("userdc")
end)
