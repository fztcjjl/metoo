local UserMultiEntity = require "UserMultiEntity"

local EntityType = class("d_building", UserMultiEntity)

function EntityType:ctor()
	EntityType.super.ctor(self)
	self.tbname = "d_building"
end

return EntityType.new()
