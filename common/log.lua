local skynet = require "skynet"
require "skynet.manager"
local logger = require "log.core"
 
local CMD = {}

function CMD.start()
	logger.init(tonumber(skynet.getenv("log_level")) or 0,
		tonumber(skynet.getenv("log_rollsize")) or 1024,
		tonumber(skynet.getenv("log_flushinterval")) or 5,
		skynet.getenv("log_dirname") or "log",
		skynet.getenv("log_basename") or "test")
end

function CMD.stop( )
	logger.exit()
end

function CMD.debug(name, msg)
	logger.debug(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

function CMD.info(name, msg)
	logger.info(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

function CMD.warning(name, msg)
	logger.warning(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

function CMD.error(name, msg)
	logger.error(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

function CMD.fatal(name, msg)
	logger.fatal(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		if cmd == "start" or cmd == "stop" then
			skynet.retpack(f(...))
		else
			f(...)
		end
	end)

	skynet.register(SERVICE_NAME)
end)
