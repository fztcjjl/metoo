local skynet = require "skynet"
require "skynet.manager"
local snax = require "snax"

-- 玩家相关的dc列表
local userdc_list = {
	"userdc",
}

local services = {}
local CMD = {}

function CMD.start()
	for _, name in pairs(userdc_list) do
		services[name] = assert(snax.uniqueservice(name))
	end
end

function CMD.load(uid)
	for _, service in pairs(services) do
		service.req.load(uid)
	end
end

function CMD.unload(uid)
	for _, service in pairs(services) do
		service.req.unload(uid)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(SERVICE_NAME)
end)
