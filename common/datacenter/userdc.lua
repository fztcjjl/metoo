local skynet = require "skynet"
local snax = require "snax"
local EntityFactory = require "EntityFactory"

local entUser
local entUserCustom

function init(...)
	entUser = EntityFactory.get("d_user")
	entUser:init()

	entUserCustom = EntityFactory.get("d_user_custom")
	entUserCustom:init()
	entUserCustom:load()
end

function exit(...)
end

function response.load(uid)
	if not uid then return end
	entUser:load(uid)
end

function response.unload(uid)
	if not uid then return end
	entUser:unload(uid)
end


function response.getvalue(uid, key)
	return entUser:getValue(uid, key)
end

function response.setvalue(uid, key, value)
	return entUser:setValue(uid, key, value)
end


function response.add(row)
	return entUser:add(row)
end

function response.delete(row)
	return entUser:delete(row)
end

function response.user_addvalue(uid, key, n)
	local value = entUser:getValue(uid, key)
	value = value + n
	local ret = entUser:setValue(uid, key, value)
	return ret, value
end

function response.get(uid)
	return entUser:get(uid)
end

function response.check_rolename_exists(name)
	if table.empty(entUserCustom:get(name)) then
		return false
	end
	return true
end

function response.check_role_exists(uid)
	if not entUser:getValue(uid, "uid") then
		return false
	end
	return true
end
