require "UserMultiEntity"

local EntityType = class(UserMultiEntity)

function EntityType:ctor()
	self.tbname = "d_building"
	self.tbschema = {
id = "number",
uid = "number",
build_type = "number",
level = "number",
starlevel = "number",
quality = "number",
}
end

return EntityType.new()
