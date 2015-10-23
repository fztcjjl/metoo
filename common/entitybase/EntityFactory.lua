local M = {}
local entities = {}		-- 保存实体对象

-- 工厂方法，获取具体对象，name为表名
function M.get(name)
	if entities[name] then
		return entities[name]
	end

	local ent = require(name)
	entities[name] = ent
	return ent
end

return M
