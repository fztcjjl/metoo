require "CommonEntity"

local EntityType = class(CommonEntity)

function EntityType:ctor()
	self.tbname = "d_account"
end

return EntityType.new()
