local skynet = require "skynet"

skynet.start(function()
	print("Server start")
	skynet.uniqueservice("entitytest")
	skynet.exit()
end)
