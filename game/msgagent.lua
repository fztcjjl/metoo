local skynet = require "skynet"
local queue = require "skynet.queue"
local snax = require "snax"
local netpack = require "netpack"
local protobuf = require "protobuf"

local cs = queue()
local UID
local SUB_ID
local SECRET
--local user_dc
local afktime = 0

local gate		-- 游戏服务器gate地址
local CMD = {}

local worker_co
local running = false

local timer_list = {}

local function add_timer(id, interval, f)
	local timer_node = {}
	timer_node.id = id
	timer_node.interval = interval
	timer_node.callback = f
	timer_node.trigger_time = skynet.now() + interval

	timer_list[id] = timer_node
end

local function del_timer(id)
	timer_list[id] = nil
end

local function clear_timer()
	timer_list = {}
end

local function dispatch_timertask()
	local now = skynet.now()
	for k, v in pairs(timer_list) do
		if now >= v.trigger_time then
			v.callback()
			v.trigger_time = now + v.interval
		end
	end
end

local function worker()
	local t = skynet.now()
	while true do
		dispatch_timertask()
		local n = skynet.now() + 100 - t
		skynet.sleep(n)
		t = t + 100
	end
end

local function logout()
	if running then
		running = false
		skynet.wakeup(worker_co)	-- 通知协程退出
	end

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

-- 空闲登出
local function idle()
	if afktime > 0 then
		if skynet.time() - afktime >= 60 then		-- 玩家断开连接后一分钟强制登出
			logout()
		end
	end
end

local function reg_timers()
	add_timer(1, 500, idle)
end

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
end

-- 玩家登录游服，握手成功后调用
function CMD.auth(source, uid)
	LOG_INFO(string.format("%s is real login", uid))
	LOG_INFO("call dcmgr to load user data uid=%d", uid)
	skynet.call("dcmgr", "lua", "load", uid)	-- 加载玩家数据，重复加载是无害的

	if not running then
		running = true
		reg_timers()
		worker_co = skynet.fork(worker)
	end
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

	local result = msg_pack(data)
	LOG_DEBUG("process %s time used %f ms", name, (skynet.time()-begin)*10)

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
	--user_dc = snax.uniqueservice("userdc")
end)
