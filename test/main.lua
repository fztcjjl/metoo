local skynet = require "skynet"

skynet.start(function()
	print("Server start")
	local console = skynet.newservice("console")
	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")
	skynet.uniqueservice("entitytest")
	skynet.exit()
end)
