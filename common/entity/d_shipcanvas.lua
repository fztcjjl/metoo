require "UserMultiEntity"

local EntityType = class(UserMultiEntity)

function EntityType:ctor()
	self.tbname = "d_shipcanvas"
end

return EntityType.new()
