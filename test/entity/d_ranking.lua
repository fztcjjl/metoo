local CommonEntity = require "CommonEntity"

local EntityType = class("d_ranking", CommonEntity)

function EntityType:ctor()
	EntityType.super.ctor(self)
	self.tbname = "d_ranking"
end

return EntityType.new()
