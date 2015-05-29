require "UserMultiEntity"

local EntityType = class(UserMultiEntity)

function EntityType:ctor()
	self.tbname = "d_item"
end

return EntityType.new()
