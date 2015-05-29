local skynet = require "skynet"
require "UserEntity"

-- UserSingleEntity
UserSingleEntity = class(UserEntity)

-- self.recordset格式如下：
--[[
{
	[uid1] = { field1 = 1, field2 = 2 },
	[uid2] = { field1 = 1, field2 = 2 }
}
--]]

function UserSingleEntity:ctor()
	self.ismulti = false		-- 是否多行记录
end

function UserSingleEntity:dtor()
end

-- 加载玩家数据
function UserSingleEntity:Load(uid)
	if not self.recordset[uid] then
		local record = skynet.call("dbmgr", "lua", "load_user_single", self.tbname, uid)
		if record then
			self.recordset[uid] = record
		end
	end

end

-- 将内存中的数据先同步回redis,再从redis加载到内存（该方法要不要待定）
function UserSingleEntity:ReLoad(uid)

end

-- 卸载玩家数据
function UserSingleEntity:UnLoad(uid)
	local rs = self.recordset[uid]
	if rs then
		for k, v in pairs(rs) do
			rs[k] = nil
		end

		self.recordset[uid] = nil

		-- 是否需要移除待定
		-- 从redis删除，但不删除mysql中的数据
	end
end

-- record中包含uid字段（如果表主键是uid字段，不需要包含）,record为k,v形式table
-- 内存中不存在，则添加，并同步到redis
function UserSingleEntity:Add(record)
	if record.uid and self.recordset[record.uid] then return end		-- 记录已经存在，返回

	local id = record[self.pk]
	if not id or id == 0 then
		id = self:GetNextId()
		record[self.pk] = id
	end

	local ret = skynet.call("dbmgr", "lua", "add", self.tbname, record, self.type)
	if ret then
		self.recordset[record.uid] = record
	end

	return ret, record
end

-- record中包含uid字段,record为k,v形式table
-- 从内存中删除，并同步到redis
function UserSingleEntity:Delete(record)
	if not record.uid then return end

	local ret = skynet.call("dbmgr", "lua", "delete", self.tbname, record, self.type)
	if ret then 
		self.recordset[record.uid] = nil
	end

	return ret
end

-- record中包含uid字段,record为k,v形式table
-- 仅从内存中移除，但不同步到redis
function UserSingleEntity:Remove(record)
	if not record.uid or not self.recordset[record.uid] then return end		-- 记录不存在，返回
	self.recordset[record.uid] = nil

	return true
end

-- record中包含uid字段,record为k,v形式table
function UserSingleEntity:Update(record)
	if not record.uid or not self.recordset[record.uid] then return end		-- 记录不存在，返回

	local ret = skynet.call("dbmgr", "lua", "update", self.tbname, record, self.type)
	if ret then
		for k, v in pairs(record) do
			self.recordset[record.uid][k] = v
		end
	end

	return ret
end

-- 从内存中获取，如果不存在，说明是其他的离线玩家数据，则加载数据到redis
-- field为空，获取整行记录，返回k,v形式table
-- field为字符串表示获取单个字段的值，如果字段不存在，返回nil
-- field为一个数组形式table，表示获取数组中指定的字段的值，返回k,v形式table
function UserSingleEntity:Get(uid, field)
	-- 内存中存在
	local record

	if self.recordset[uid] then
		if not field then
			record = self.recordset[uid]
		elseif type(field) == "string" then
			record = self.recordset[uid][field]
		elseif type(field) == "table" then
			record = {}
			for i=1, #field do
				local t = self.recordset[uid]
				record[field[i]] = t[field[i]]
			end
		end
		return record
	end

	-- 从redis获取，如果redis不存在，从mysql加载
	local orifield = field
	if type(field) == "string" then
		field = { field }
	end
	record = skynet.call("dbmgr", "lua", "get_user_single", self.tbname, uid, field) --不存在返回空的table {}
	if not table.empty(record) then
		self.recordset[uid] = record

		if type(orifield) == "string" then
			return record[orifield]
		end
	end

	if table.empty(record) and type(orifield) == "string" then return end

	return record
end

-- field为字符串表示获取单个字段的值
-- field为一个数组形式table，表示获取数组中指定的字段的值，返回k,v形式table
function UserSingleEntity:GetValue(uid, field)
	if not field then return end
	local record = self:Get(uid, field)
	if record then
		return record
	end
end

-- 成功返回true，失败返回false或nil
-- 设置单个字段的值，field为字符串，value为值
-- 设置多个字段的值，field为k,v形式table，value为空
function UserSingleEntity:SetValue(uid, field, value)
	local record = {}
	record["uid"] = uid
	if value then
		record[field] = value
	else
		for k, v in pairs(field) do
			record[k] = v
		end
	end

	return self:Update(record)
end
