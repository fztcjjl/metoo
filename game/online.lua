local skynet = require "skynet"
require "skynet.manager"
local snax = require "snax"

local CMD = {}

local function send_building(uid, fd)
	local ok, obj = pcall(snax.uniqueservice, "building")
	if not ok then
		LOG_ERROR(string.format("unknown module %s", "building"))
	else
		obj.req.online(uid, fd)
	end
end

function CMD.init()
	protobuf.register_file("protocol/building.pb")
end

function CMD.online(uid, fd)
	send_building(uid, fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(SERVICE_NAME)
end)

