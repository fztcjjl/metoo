require "ConfigEntity"

local EntityType = class(ConfigEntity)

function EntityType:ctor()
	self.tbname = "s_config"
	self.tbschema = {
id = "number",
data1 = "number",
data2 = "number",
data3 = "number",
data4 = "number",
data5 = "number",
str1 = "string",
str2 = "string",
str3 = "string",
str4 = "string",
str5 = "string",
description = "string",
}
end

return EntityType.new()
