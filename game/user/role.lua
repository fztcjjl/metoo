local skynet = require "skynet"
local snax = require "snax"
local protobuf = require "protobuf"

local user_dc

function init(...)
	user_dc = snax.uniqueservice("userdc")
end

function exit(...)
end

function response.roleinit(uid, name)
	local data = {
		uid = uid,
		name = name,
		level = 1,
		exp = 0,
		rtime = os.time(),
		ltime = os.time()
	}

	local ret = user_dc.req.add(data)
	
	-- 初始化角色其他数据
	return ret
end
