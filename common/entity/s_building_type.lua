require "ConfigEntity"

local EntityType = class(ConfigEntity)

function EntityType:ctor()
	self.tbname = "s_building_type"
	--[[self.tbschema = {
id = "number",
name = "string",
type = "number",
shapeid = "number",
starlevel = "number",
quality = "number",
modeltype = "number",
damage = "number",
resource = "number",
build = "number",
levellimit = "number",
level = "number",
coin = "number",
wood = "number",
stone = "number",
steel = "number",
hp1 = "number",
hp2 = "number",
phy_attack = "number",
magic_attack = "number",
physicaldefend1 = "number",
magicdefend1 = "number",
physicaldefend2 = "number",
magicdefend2 = "number",
add_attr1 = "number",
value1 = "number",
add_attr2 = "number",
value2 = "number",
add_attr3 = "number",
value3 = "number",
data0 = "number",
data1 = "number",
skillid = "number",
hidecd = "number",
}--]]
end

return EntityType.new()
