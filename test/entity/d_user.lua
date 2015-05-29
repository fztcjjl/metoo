require "UserSingleEntity"

local EntityType = class(UserSingleEntity)

function EntityType:ctor()
	self.tbname = "d_user"
end

return EntityType.new()
