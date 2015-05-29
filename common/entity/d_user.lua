require "UserSingleEntity"

local EntityType = class(UserSingleEntity)

function EntityType:ctor()
	self.tbname = "d_user"
	self.tbschema = {
uid = "number",
name = "string",
level = "number",
exp = "number",
coin = "number",
wood = "number",
stone = "number",
steel = "number",
diamond = "number",
hdiamond = "number",
rtime = "number",
sociatyid = "number",
stage = "number",
}
end

return EntityType.new()
