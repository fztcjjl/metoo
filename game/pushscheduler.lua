local skynet = require "skynet"
local snax = require "snax"

local queue = {}

local function do_push()
	while true do
		skynet.sleep(1)
		for k, v in pairs(queue) do
			if not uid then		-- 所有在线玩家(排除exclude_uid)
				local agents = skynet.call("gated", "lua", "get_agents")
				for uid, agent in pairs(agents) do
					if not v.exclude_uid or uid ~= v.exclude_uid then
						skynet.call(agent, "lua", "push", v.name, v.data)
					end
				end
			elseif type(v.uid) == "number" then		-- 单个玩家
				local agent = skynet.call("gated", "lua", "get_agent")
				if agent then
					skynet.call(agent, "lua", v.name, v.data)
				end
			elseif type(v.uid) == "table" then		-- 多个玩家
				for _, uid in pairs(v.uid) do
					local agent = skynet.call("gated", "lua", "get_agent")
					if agent then
					skynet.call(agent, "lua", v.name, v.data)
				end
			end
			queue[k] = nil
		end
	end
end

function init(...)
	skynet.fork(do_push)
end

function exit(...)
end

function response.push(uid, name, data, exclude_uid)
	table.insert(queue, { uid = uid, name = name, data = data, exclude_uid = exclude_uid })
end
