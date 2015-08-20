local skynet = require "skynet"
local snax = require "snax"
local EntityFactory = require "EntityFactory"

local EntAccount

function init(...)
	EntAccount = EntityFactory.Get("d_account")
	EntAccount:Init()
	EntAccount:Load()
end

function exit(...)

end

function response.add(row)
	return EntAccount:Add(row)
end

function response.delete(row)
	return EntAccount:Delete(row)
end

function response.get(sdkid, pid)
	return EntAccount:Get(sdkid, pid)
end

function response.update(row)
	return EntAccount:Update(row)
end

function response.get_nextid()
	return EntAccount:GetNextId()
end