local skynet = require "skynet"

-- 定义Entity类型
local Entity = class("Entity")

function Entity:ctor()
	self.recordset = {}			-- 存放记录集
	setmetatable(self.recordset, { __mode = "k" })
	self.tbname = ""			-- 表名
	--self.sql = ""				-- sql语句
	--self.tbschema = {}		-- 表结构
	self.pk = ""				-- 主键字段
	self.key = ""				-- key
	self.indexkey = ""			-- indexkey
	self.type = 0				-- 表类型：1、config，2、user，3、common
end

function Entity:dtor()
end

-- 获取redis下一个编号
function Entity:GetNextId()
	return do_redis({ "incr", self.tbname .. ":" .. self.pk })
end

function Entity:Init()
	self.pk, self.key, self.indexkey = skynet.call("dbmgr", "lua", "get_table_key", self.tbname, self.type)
	--self.tbschema = skynet.call("dbmgr", "lua", "get_schema", self.tbname)
end

return Entity
