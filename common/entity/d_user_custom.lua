local CommonEntity = require "CommonEntity"

local EntityType = class("d_user_custom", CommonEntity)

function EntityType:ctor()
	EntityType.super.ctor(self)
	self.tbname = "d_user"
end

return EntityType.new()
