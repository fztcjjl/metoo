local skynet = require "skynet"
local snax = require "snax"
local EntityFactory = require "EntityFactory"

local entConfig
local entUser
local entItem
local entRanking

function init(...)
	entConfig = EntityFactory.get("s_config")
	entConfig:init()
	entConfig:load()

	entRanking = EntityFactory.get("d_ranking")
	entConfig:init()
	entConfig:load()
	
	entUser = EntityFactory.get("d_user")
	entUser:init()

	entItem = EntityFactory.get("d_item")
	entItem:init()
end

function exit(...)

end

function response.init(mgr)
	
end

function response.load(uid)
	if uid then
		entUser:load(uid)
	end
end

function response.unload(uid)
	if uid then
		entUser:unload(uid)
	end
end

function response.user_get(uid)
	return entUser:get(uid)
end

function response.user_setvalue(uid, key)
	return entUser:setValue(uid, key, value)
end

function response.user_getvalue(uid, key)
	return entUser:getValue(uid, key)
end

function response.user_addvalue(uid, key, value)
	local v = entUser:getValue(uid, key)
	v = v + value
	local ret = entUser:setValue(uid, key, v)
	return ret, v
end

function response.user_add(row)
	return entUser:add(row)
end

function response.user_delete(uid)
	local row = { uid = uid }
	return entUser:delete(row)
end


function response.item_get(uid)
	return entItem:get(uid)
end

function response.item_getvalue(uid, id, key)
	return entItem:getValue(uid, id, key)
end

function response.item_setvalue(uid, id, key, value)
	return entItem:setValue(uid, id, key, value)
end
