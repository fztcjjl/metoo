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

	if ret then
		local userinfo = user_dc.req.get(uid)
		local name, resp = pb_encode("user.UserInfoResponse", userinfo)

		local function format_errmsg(errno, errmsg)
			local err = {}
			err.code = errno or 0
			err.desc = errmsg
			return err
		end
		local x = {}
		x.name = name
		x.payload = resp
		data.errmsg = format_errmsg(0)

		send_client(data.fd, x)
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
	local name, resp = pb_encode("user.UserInfoResponse", userinfo)

	local function format_errmsg(errno, errmsg)
		local err = {}
		err.code = errno or 0
		err.desc = errmsg
		return err
	end
	local x = {}
	x.name = name
	x.payload = resp
	data.errmsg = format_errmsg(0)

	send_client(data.fd, x)
end

function response.UserInfoRequest(data)
	local args = pb_decode(data)
	local userinfo = user_dc.req.get(args.uid)
	print(userinfo)
	local name, resp = pb_encode("user.UserInfoResponse", userinfo)

	local function format_errmsg(errno, errmsg)
		local err = {}
		err.code = errno or 0
		err.desc = errmsg
		return err
	end

	local x = {}
	x.name = name
	x.payload = resp
	data.errmsg = format_errmsg(0)

	send_client(data.fd, x)
	-- return name, resp
end
