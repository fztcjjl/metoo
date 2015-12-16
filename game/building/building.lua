local skynet = require "skynet"
local snax = require "snax"
local protobuf = require "protobuf"

local build_dc

function init(...)
	protobuf.register_file("protocol/building.pb")
	build_dc = snax.uniqueservice("buildingdc")
end

function exit(...)
end

function response.online(uid, fd)
	local data = {}
	local buildings = build_dc.req.get(uid)
	data.buildings = {}
	for _, v in pairs(buildings) do
		table.insert(data.buildings, v)
	end
	send_client(fd, "building.BuildingInfoResponse", data)
end
