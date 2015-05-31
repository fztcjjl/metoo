local skynet = require "skynet"
--local protobuf = require "protobuf"

function do_redis(args, uid)
	local cmd = assert(args[1])
	args[1] = uid
	return skynet.call("redispool", "lua", cmd, table.unpack(args))
end

function LOG_DEBUG(fmt, ...)
	local msg = string.format(fmt, ...)
	--msg = msg .. "\n"
	skynet.send("log", "lua", "debug", SERVICE_NAME, msg)
end

function LOG_INFO(fmt, ...)
	local msg = string.format(fmt, ...)
	--msg = msg .. "\n"
	skynet.send("log", "lua", "info", SERVICE_NAME, msg)
end

function LOG_WARNING(fmt, ...)
	local msg = string.format(fmt, ...)
	msg = msg .. "\n"
	skynet.send("log", "lua", "warning", SERVICE_NAME, msg)
end

function LOG_ERROR(fmt, ...)
	local msg = string.format(fmt, ...)
	msg = msg .. "\n"
	skynet.send("log", "lua", "error", SERVICE_NAME, msg)
end

function LOG_FATAL(fmt, ...)
	local msg = string.format(fmt, ...)
	msg = msg .. "\n"
	skynet.send("log", "lua", "fatal", SERVICE_NAME, msg)
end

function check( ... )
	-- body
end
