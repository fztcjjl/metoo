local skynet = require "skynet"
local snax = require "snax"
local entity = require "Entity"

local EntConfig
local EntUser
local EntItem
local EntRanking

function init(...)
	EntConfig = entity.Get("s_config")
	EntConfig:Init()
	EntConfig:Load()

	EntRanking = entity.Get("d_ranking")
	EntConfig:Init()
	EntConfig:Load()
	
	EntUser = entity.Get("d_user")
	EntUser:Init()

	EntItem = entity.Get("d_item")
	EntItem:Init()
end

function exit(...)

end

function response.init(mgr)
	
end

function response.load(uid)
	if uid then
		EntUser:Load(uid)
	end
end

function response.unload(uid)
	if uid then
		EntUser:UnLoad(uid)
	end
end

function response.user_get(uid)
	return EntUser:Get(uid)
end

function response.user_setvalue(uid, key)
	return EntUser:SetValue(uid, key, value)
end

function response.user_getvalue(uid, key)
	return EntUser:GetValue(uid, key)
end

function response.user_addvalue(uid, key, value)
	local v = EntUser:GetValue(uid, key)
	v = v + value
	local ret = EntUser:SetValue(uid, key, v)
	return ret, v
end

function response.user_add(row)
	return EntUser:Add(row)
end

function response.user_delete(uid)
	local row = { uid = uid }
	return EntUser:Delete(row)
end


function response.item_get(uid)
	return EntItem:Get(uid)
end

function response.item_getvalue(uid, id, key)
	return EntItem:GetValue(uid, id, key)
end

function response.item_setvalue(uid, id, key, value)
	return EntItem:SetValue(uid, id, key, value)
end
