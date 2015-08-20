local UserSingleEntity = require "UserSingleEntity"

local EntityType = class("d_user", UserSingleEntity)

function EntityType:ctor()
	EntityType.super.ctor(self)
	self.tbname = "d_user"
end

return EntityType.new()
