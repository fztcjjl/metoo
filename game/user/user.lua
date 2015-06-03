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
	local uid = args.uid
	local username = args.name
	if not user_dc.req.check_role_exists(uid) then
		local ret = role_obj.req.roleinit(uid, username)
		if not ret then
			return nil, nil, ErrorCode.E_DB_ERROR
		end
	else
		LOG_ERROR("uid %d has role, role init failed", uid)
		return nil, nil, ErrorCode.E_ROLE_EXISTS
	end

	local name, resp = pb_encode("user.RoleInitResonpse", {})
	return name, resp
end
