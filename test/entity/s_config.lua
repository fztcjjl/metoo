local ConfigEntity = require "ConfigEntity"

local EntityType = class("s_config", ConfigEntity)

function EntityType:ctor()
	EntityType.super.ctor(self)
	self.tbname = "s_config"
end

return EntityType.new()
