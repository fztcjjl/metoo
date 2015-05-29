require "CommonEntity"

local EntityType = class(CommonEntity)

function EntityType:ctor()
	self.tbname = "d_ranking"
	self.tbschema = {
id = "number",
uid = "number",
attack_win = "number",
defend_win = "number",
reward = "number",
}
end

return EntityType.new()
