skynetroot = "./skynet/"
thread = 8
logger = nil
logpath = "."
harbor = 0
start = "main"	-- main script
bootstrap = "snlua bootstrap"	-- The service for bootstrap

-- 集群名称配置文件
cluster = "./cluster/clustername.lua"

log_dirname = "log"
log_basename = "login"

loginservice = "./login/?.lua;" ..
			   "./common/?.lua;" ..
			   "./common/cluster/?.lua;" ..
			   "./common/datacenter/?.lua"

-- LUA服务所在位置
luaservice = skynetroot .. "service/?.lua;" .. loginservice
snax = loginservice

-- 用于加载LUA服务的LUA代码
lualoader = skynetroot .. "lualib/loader.lua"
preload = "./global/preload.lua"	-- run preload.lua before every lua service run

-- C编写的服务模块路径
cpath = skynetroot .. "cservice/?.so"

-- 将添加到 package.path 中的路径，供 require 调用。
lua_path = skynetroot .. "lualib/?.lua;" ..
		   "./lualib/?.lua;" ..
		   "./global/?.lua;" ..
		   "./common/entitybase/?.lua;" ..
		   "./common/entity/?.lua"

-- 将添加到 package.cpath 中的路径，供 require 调用。
lua_cpath = skynetroot .. "luaclib/?.so;" .. "./luaclib/?.so"

-- 后台模式
--daemon = "./login.pid"

port = 5188					-- 监听端口

mysql_maxconn = 10			-- mysql数据库最大连接数
mysql_host = "127.0.0.1"	-- mysql数据库主机
mysql_port = 3306			-- mysql数据库端口
mysql_db = "metoo"			-- mysql数据库库名
mysql_user = "root"			-- mysql数据库帐号
mysql_pwd = "123456"		-- mysql数据库密码

redis_maxinst = 1			-- redis最大实例数

redis_host1 = "127.0.0.1"	-- redis数据库IP
redis_port1 = 6379			-- redis数据库端口
redis_auth1 = "123456"		-- redis数据库密码

