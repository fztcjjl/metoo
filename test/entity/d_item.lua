local UserMultiEntity = require "UserMultiEntity"

local EntityType = class("d_item", UserMultiEntity)

function EntityType:ctor()
	EntityType.super.ctor(self)
	self.tbname = "d_item"
end

return EntityType.new()
