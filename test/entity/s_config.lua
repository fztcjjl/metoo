require "ConfigEntity"

local EntityType = class(ConfigEntity)

function EntityType:ctor()
	self.tbname = "s_config"
end

return EntityType.new()
