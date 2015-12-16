local skynet = require "skynet"
local snax = require "snax"
local protobuf = require "protobuf"

local user_dc
local role_obj
local build_dc

function init(...)
	protobuf.register_file("protocol/user.pb")
	user_dc = snax.uniqueservice("userdc")
	role_obj = snax.uniqueservice("role")
	build_dc = snax.uniqueservice("buildingdc")
end

function exit(...)
end

local function init_building(uid)

	local init_data = user_dc.req.get_roleinit(1)

	local building_info = string.split(init_data.str1, ";")

	for _, v in pairs(building_info) do
		local info = string.split(v, ",")
		local row = { uid = uid, type = tonumber(info[1]), level = tonumber(info[2]) } 
		build_dc.req.add(row)
	end

	LOG_INFO("init_building ok, uid %d", uid)

	return true
end

function response.load(uid)
	if not uid then return end
	EntUser:load(uid)
end

function response.unload(uid)
	if not uid then return end
	EntUser:unload(uid)
end

function response.RoleInitRequest(data)
	local args = pb_decode(data)
	local uid = data.uid
	local fd = data.fd
	if user_dc.req.check_role_exists(uid) then
		LOG_ERROR("uid %d has role, role init failed", uid)
		return
	end

	local row = {
		uid = uid,
		name = args.name,
		level = 1,
		exp = 0,
		rtime = os.time(),
		ltime = os.time()
	}

	local ret = user_dc.req.add(row)

	init_building(uid)

	if ret then
		local userinfo = user_dc.req.get(uid)
		local proto = "user.UserInfoResponse"
		local payload = pb_encode(proto, userinfo)

		send_client(data.fd, proto, payload)
	end
end

function response.RoleRenameRequest(data)
	local args = pb_decode(data)
	local uid = data.uid
	local fd = data.fd

	if not user_dc.req.check_role_exists(uid) then
		LOG_ERROR("uid %d has not a role, role rename failed", uid)
		return
	end

	local ret = user_dc.req.setvalue(uid, "name", args.name)
	
	if not ret then
		return
	end

	local userinfo = user_dc.req.get(uid)
	send_client(data.fd, "user.UserInfoResponse", userinfo)
end

function response.UserInfoRequest(data)
	local args = pb_decode(data)
	local userinfo = user_dc.req.get(args.uid)
	send_client(data.fd, "user.UserInfoResponse", userinfo)
end

function response.roleinit(uid)
	if user_dc.req.check_role_exists(uid) then
		return
	end

	local row = {
		uid = uid,
		name = tostring(uid),
		level = 1,
		exp = 0,
		rtime = os.time(),
		ltime = os.time()
	}

	local ret = user_dc.req.add(row)

	init_building(uid)
end
