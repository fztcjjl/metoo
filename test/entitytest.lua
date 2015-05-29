local skynet = require "skynet"
local snax = require "snax"

local config = {
	{ name = "s_config", key = "id" },
}

local user = {
	{ name = "d_user", key = "uid" },
	{ name = "d_item", key = "id", indexkey = "uid" },
}

local common = {
	{ name = "d_ranking", key = "uid" },
}

skynet.start(function()
	-- config表与common表是游服启动时加载
	-- 启动数据服务，config表与common表数据加载到redis
	local dbmgr = skynet.uniqueservice("dbmgr")
	skynet.call(dbmgr, "lua", "start", config, user, common)

	-- 启动各个数据中心，config表与common表数据加载到各个数据中心内存
	local dc = snax.uniqueservice("testdc")

	-- 以下假设uid = 1的玩家登录
	dc.req.load(1)

	print("UserSingleEntity test")
	print(dc.req.user_get(1))	-- 打印uid = 1的玩家记录
	print(dc.req.user_getvalue(1, "name"))	-- 输出uid = 1的玩家名称

	local ret
	local row1
	local row2
	ret, row = dc.req.user_add({ name="test1", level=2 })
	if ret then
		print(row)
	end

	ret, row2 = dc.req.user_add({ name="test2", level=3 })
	if ret then
		print(row2)
	end

	dc.req.user_delete(row2.uid)

	print("UserMultEntity test")
	print(dc.req.item_get(1))
	print(dc.req.item_getvalue(1, 1, "itemid"))
	print(dc.req.item_getvalue(1, 1, { "itemid", "superposition" }))

	dc.req.item_setvalue(1, 1, "superposition", 100)
end)
