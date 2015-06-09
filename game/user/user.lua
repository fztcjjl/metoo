local skynet = require "skynet"
local snax = require "snax"
local protobuf = require "protobuf"

local user_dc
local role_obj

function init(...)
	protobuf.register_file("protocol/user.pb")
	user_dc = snax.uniqueservice("userdc")
	role_obj = snax.uniqueservice("role")
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

function response.RoleInitRequest(data)
	local args = pb_decode(data)
	local errno = role_obj.req.roleinit(args.uid, args.name)
	local name, resp = pb_encode("user.RoleInitResonpse", {})
	return name, resp, errno
end
