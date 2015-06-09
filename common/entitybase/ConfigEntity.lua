local skynet = require "skynet"
require "Entity"

-- 定义ConfigEntity类型
ConfigEntity = class(Entity)

function ConfigEntity:ctor()
	self.type = 1
end

function ConfigEntity:dtor()

end

function ConfigEntity:Init()

end

function ConfigEntity:Load()
	--if table.empty(self.recordset) then
		local rs = skynet.call("dbmgr", "lua", "get_config", self.tbname)
		if rs then
			self.recordset = rs
		end
	--end
end

function ConfigEntity:Get(...)
	local t = { ... }
	assert(#t > 0)
	local key
	if #t == 1 then
		key = t[1]
	else
		key = ""
		for i = 1, #t do
			if i > 1 then
				key = key .. ":"
			end
			key = key .. tostring(t[i])
		end
	end

	return self.recordset[key] or {}
end


function ConfigEntity:GetAll( )
	return self.recordset
end
