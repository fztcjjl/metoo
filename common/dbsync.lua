local skynet = require "skynet"
require "skynet.manager"

local queue = {}

local CMD = {}

function CMD.start()
end

function CMD.stop()
end

function CMD.sync(sql)
    table.insert(queue, sql)
end

local function sync_impl()
    while true do
        for k, sql in pairs(queue) do
            skynet.call("mysqlpool", "lua", "execute", sql)
            queue[k] = nil
        end
        skynet.sleep(500)
    end
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = assert(CMD[cmd], cmd .. "not found")
        skynet.retpack(f(...))
    end)
    skynet.fork(sync_impl)
    skynet.register(SERVICE_NAME)
end)

