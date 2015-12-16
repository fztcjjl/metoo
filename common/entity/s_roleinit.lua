local ConfigEntity = require "ConfigEntity"

local EntityType = class("s_roleinit", ConfigEntity)

function EntityType:ctor()
	EntityType.super.ctor(self)
	self.tbname = "s_roleinit"
end

return EntityType.new()
