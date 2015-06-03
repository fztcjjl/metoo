require "CommonEntity"

local EntityType = class(CommonEntity)

function EntityType:ctor()
	self.tbname = "d_user"
end

return EntityType.new()
