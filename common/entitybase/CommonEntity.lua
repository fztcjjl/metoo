local skynet = require "skynet"
local Entity = require "Entity"

-- CommonEntity
local CommonEntity = class("CommonEntity", Entity)

function CommonEntity:ctor()
	CommonEntity.super.ctor(self)
	self.type = 3
end

-- 加载整张表数据
function CommonEntity:load()
	if table.empty(self.recordset) then
		local rs = skynet.call("dbmgr", "lua", "get_common", self.tbname)
		if rs then
			self.recordset = rs
		end
	end

end

--[[
-- 将内存中的数据先同步回redis,再从redis加载到内存（该方法要不要待定）
function CommonEntity:reload()

end

-- 卸载整张表数据
function CommonEntity:unload()

end
--]]

-- row中包含pk字段,row为k,v形式table
-- 内存中不存在，则添加，并同步到redis
function CommonEntity:add(row, nosync)
	if row.id and self.recordset[row.id] then return end		-- 记录已经存在，返回

	local id = row[self.pk]
	if not id or id == 0 then
		id = self:getNextId()
		row[self.pk] = id
	end

	local ret = skynet.call("dbmgr", "lua", "add", self.tbname, row, self.type, nosync)

	if ret then
		key = self:getKey(row)
		self.recordset[key] = row
	end

	return true
end

-- row中包含pk字段,row为k,v形式table
-- 从内存中删除，并同步到redis
function CommonEntity:delete(row, nosync)
	local id = row[self.pk]
	if not self.recordset[id] then return end		-- 记录不存在，返回

	local ret = skynet.call("dbmgr", "lua", "delete", self.tbname, row, self.type, nosync)

	if ret then
		key = self:getKey(row)
		self.recordset[key] = nil
	end

	return true
end

-- row中包含pk字段,row为k,v形式table
-- 仅从内存中移除，但不同步到redis
function CommonEntity:remove(row)
	local id = row[self.pk]
	if not self.recordset[id] then return end		-- 记录不存在，返回

	key = self:getKey(row)
	self.recordset[key] = nil

	return true
end

-- row中包含pk字段,row为k,v形式table
function CommonEntity:update(row, nosync)
	local id = row[self.pk]
	if not self.recordset[id] then return end		-- 记录不存在，返回
	

	local ret = skynet.call("dbmgr", "lua", "update", self.tbname, row, self.type, nosync)

	if ret then
		key = self:getKey(row)
		for k, v in pairs(row) do
			self.recordset[key][k] = v
		end
	end

	return true
end

function CommonEntity:get(...)
	local t = { ... }
	assert(#t > 0)
	local key
	if #t == 1 then
		key = t[1]
	else
		key = ""
		for i = 1, #t do
			if i > 1 then
				key = key .. ":"
			end
			key = key .. tostring(t[i])
		end
	end

	return self.recordset[key] or {}
end

--[[
function CommonEntity:Set(id, row)
	-- 设置一行记录
end
--]]

function CommonEntity:getValue(id, field)
	local record = self:get(id)
	if record then
		return record[field]
	end
end

function CommonEntity:setValue(id, field, data)
	local record = {}
	record[self.pkfield] = id
	record[field] = data
	self:update(record)
end

function CommonEntity:getKey(row)
	local fields = string.split(self.key, ",")
	local key
	for i=1, #fields do
		if i == 1 then
			key = row[fields[i]]
		else
			key = key .. ":" .. row[fields[i]]
		end
	end

	return tonumber(key) or key
end

function CommonEntity:getAll( )
	return self.recordset
end

return CommonEntity
