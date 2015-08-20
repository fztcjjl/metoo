local skynet = require "skynet"
local snax = require "snax"
local EntityFactory = require "EntityFactory"

local EntUser
local EntUserCustom

function init(...)
	EntUser = EntityFactory.Get("d_user")
	EntUser:Init()

	EntUserCustom = EntityFactory.Get("d_user_custom")
	EntUserCustom:Init()
	EntUserCustom:Load()
end

function exit(...)
end

function response.load(uid)
	if not uid then return end
	EntUser:Load(uid)
end

function response.unload(uid)
	if not uid then return end
	EntUser:UnLoad(uid)
end


function response.getvalue(uid, key)
	return EntUser:GetValue(uid, key)
end

function response.setvalue(uid, key, value)
	return EntUser:SetValue(uid, key, value)
end


function response.add(row)
	return EntUser:Add(row)
end

function response.delete(row)
	return EntUser:Delete(row)
end

function response.user_addvalue(uid, key, n)
	local value = EntUser:GetValue(uid, key)
	value = value + n
	local ret = EntUser:SetValue(uid, key, value)
	return ret, value
end

function response.get(uid)
	return EntUser:Get(uid)
end

function response.check_rolename_exists(name)
	if table.empty(EntUserCustom:Get(name)) then
		return false
	end
	return true
end

function response.check_role_exists(uid)
	if not EntUser:GetValue(uid, "uid") then
		return false
	end
	return true
end
