require "CommonEntity"

local EntityType = class(CommonEntity)

function EntityType:ctor()
	self.tbname = "d_ranking"
end

return EntityType.new()
