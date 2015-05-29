local skynet = require "skynet"
--local protobuf = require "protobuf"

function do_redis(args, uid)
	local cmd = assert(args[1])
	args[1] = uid
	return skynet.call("redispool", "lua", cmd, table.unpack(args))
end

function check( ... )
	-- body
end
