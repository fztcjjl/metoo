local skynet = require "skynet"
local Entity = require "Entity"

-- 定义UserEntity类型
local UserEntity = class("UserEntity", Entity)

function UserEntity:ctor()
	UserEntity.super.ctor(self)
	self.ismulti = false		-- 是否多行记录
	self.type = 2
end

function UserEntity:dtor()
end

return UserEntity
