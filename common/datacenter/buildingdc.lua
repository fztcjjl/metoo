local skynet = require "skynet"
local snax = require "snax"
local EntityFactory = require "EntityFactory"

local entBuilding

function init(...)
	entBuilding = EntityFactory.get("d_building")
	entBuilding:init()
end

function exit(...)
end

function response.load(uid)
	if not uid then return end
	entBuilding:load(uid)
end

function response.unload(uid)
	if not uid then return end
	entBuilding:unload(uid)
end

function response.getvalue(uid, key)
	return entBuilding:getValue(uid, key)
end

function response.setvalue(uid, key, value)
	return entBuilding:setValue(uid, key, value)
end

function response.add(row)
	return entBuilding:add(row)
end

function response.delete(row)
	return entBuilding:delete(row)
end

function response.get(uid)
	return entBuilding:get(uid)
end
