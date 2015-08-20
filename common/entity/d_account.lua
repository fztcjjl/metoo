local CommonEntity = require "CommonEntity"

local EntityType = class("d_account", CommonEntity)

function EntityType:ctor()
	EntityType.super.ctor(self)
	self.tbname = "d_account"
end

return EntityType.new()
