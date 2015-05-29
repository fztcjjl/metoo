local skynet = require "skynet"
require "Entity"

-- 定义UserEntity类型
UserEntity = class(Entity)

function UserEntity:ctor()
	self.ismulti = false		-- 是否多行记录
	self.type = 2
end

function UserEntity:dtor()
end
