local skynet = require "skynet"
require "skynet.manager"
local redis = require "redis"

local dbname = skynet.getenv("mysql_db")

local config_table = {}
local user_table = {}
local common_table = {}

local schema = {}

local CMD = {}

local function get_primary_key(tbname)
	local sql = "select k.column_name " ..
		"from information_schema.table_constraints t " ..
		"join information_schema.key_column_usage k " ..
		"using (constraint_name,table_schema,table_name) " ..
		"where t.constraint_type = 'PRIMARY KEY' " ..
		"and t.table_schema= '".. dbname .. "'" ..
		"and t.table_name = '" .. tbname .. "'"
	
	local t = skynet.call("mysqlpool", "lua", "execute",sql)

	return t[1]["column_name"]
end

local function get_fields(tbname)
	local sql = string.format("select column_name from information_schema.columns where table_schema = '%s' and table_name = '%s'", dbname, tbname)
	local rs = skynet.call("mysqlpool", "lua", "execute", sql)
	local fields = {}
	for _, row in pairs(rs) do
		table.insert(fields, row["column_name"])
	end

	return fields
end

local function get_field_type(tbname, field)
	local sql = string.format("select data_type from information_schema.columns where table_schema='%s' and table_name='%s' and column_name='%s'",
			dbname, tbname, field)
	local rs = skynet.call("mysqlpool", "lua", "execute", sql)
	return rs[1]["data_type"]
end

local function load_schema_to_redis()
	local sql = "select table_name from information_schema.tables where table_schema='" .. dbname .. "'"
	local rs = skynet.call("mysqlpool", "lua", "execute", sql)
	for _, row in pairs(rs) do
		local tbname =row.table_name
		schema[tbname] = {}
		schema[tbname]["fields"] = {}
		schema[tbname]["pk"] = get_primary_key(tbname)

		local fields = get_fields(tbname)
		for _, field in pairs(fields) do
			local field_type = get_field_type(tbname, field)
			if field_type == "char"
			  or field_type == "varchar"
			  or field_type == "tinytext"
			  or field_type == "text"
			  or field_type == "mediumtext"
			  or field_type == "longtext" then
				schema[tbname]["fields"][field] = "string"
			else
				schema[tbname]["fields"][field] = "number"
			end
		end
	end
end

local function convert_record(tbname, record)
	for k, v in pairs(record) do
		if schema[tbname]["fields"][k] == "number" then
			record[k] = tonumber(v)
		end
	end

	return record
end

local function make_rediskey(row, key)
	local rediskey = ""
	local fields = string.split(key, ",")
	for i, field in pairs(fields) do
		if i == 1 then
			rediskey = row[field]
		else
			rediskey = rediskey .. ":" .. row[field]
		end
	end

	return rediskey
end

local function load_data_impl(config, uid)
	local tbname = config.name
	local pk = schema[tbname]["pk"]
	local offset = 0
	local sql
	local data = {}
	while true do
		if not uid then
			if not config.columns then
				sql = string.format("select * from %s order by %s asc limit %d, 1000", tbname, pk, offset)
			else
				sql = string.format("select %s from %s order by %s asc limit %d, 1000", config.columns, tbname, pk, offset)
			end
		else
			if not config.columns then
				sql = string.format("select * from %s where uid = %d order by %s asc limit %d, 1000", tbname, uid, pk, offset)
			else
				sql = string.format("select %s from %s where uid = %d order by %s asc limit %d, 1000", config.columns, tbname, uid, pk, offset)
			end
		end

		local rs = skynet.call("mysqlpool", "lua", "execute", sql)

		if #rs <= 0 then break end

		for _, row in pairs(rs) do
			local rediskey = make_rediskey(row, config.key)
			do_redis({ "hmset", tbname .. ":" .. rediskey, row, true }, uid)
			-- 建立索引
			if config.indexkey then
				local indexkey = make_rediskey(row, config.indexkey)
				do_redis({ "zadd", tbname .. ":index:" .. indexkey, 0, rediskey }, uid) 
			end

			table.insert(data, row)
			
		end

		if #rs < 1000 then break end

		offset = offset + 1000
	end

	return data
end

local function load_config_data()
	for _, v in pairs(config_table) do
		load_data_impl(v)
	end
end

local function load_common_data()
	for _, v in pairs(common_table) do
		load_data_impl(v)
	end
end

local function load_maxkey_impl(tbname)
	local pk = schema[tbname]["pk"]
	local sql = string.format("select max(%s) as maxkey from %s", pk, tbname)
	local result = skynet.call("mysqlpool", "lua", "execute", sql)
	if #result > 0 and not table.empty(result[1]) then
		do_redis({ "set", tbname .. ":" .. pk, result[1]["maxkey"] })
	end
end

local function load_maxkey()
	for k, v in pairs(user_table) do
		load_maxkey_impl(k)
	end

	for k, v in pairs(common_table) do
		load_maxkey_impl(k)
	end

end

local function load_data_to_redis()
	load_config_data()
	load_common_data()
	load_maxkey()
end

function make_pairs_table(t, fields)
	assert(type(t) == "table", "make_pairs_table t is not table")

	local data = {}

	if not fields then
		for i=1, #t, 2 do
			data[t[i]] = t[i+1]
		end
	else
		for i=1, #t do
			data[fields[i]] = t[i]
		end
	end

	return data
end

function CMD.start(config, user, common)
	local mysqlpool = skynet.uniqueservice("mysqlpool")
	skynet.call(mysqlpool, "lua", "start")

	local redispool = skynet.uniqueservice("redispool")
	skynet.call(redispool, "lua", "start")

	local dbsync = skynet.uniqueservice("dbsync")
	skynet.call(dbsync, "lua", "start")

	for _, v in pairs(config) do
		config_table[v.name] = v
	end

	for _, v in pairs(user) do
		user_table[v.name] = v
	end

	for _, v in pairs(common) do
		common_table[v.name] = v
	end

	load_schema_to_redis()
	load_data_to_redis()
end

function CMD.stop()
end

-- 从redis获取config类型表数据
function CMD.get_config(tbname)
	local data = {}
	local config = config_table[tbname]
	local keys = do_redis({ "keys", tbname .. ":*" })

	for _, v in pairs(keys) do
		local row = do_redis({ "hgetall", v })
		row = make_pairs_table(row)
		row = convert_record(tbname, row)
		local key = make_rediskey(row, config.key)
		data[key] = row
	end

	return data
end

-- 从redis获取common类型表数据
function CMD.get_common(tbname)
	local data = {}
	local config = common_table[tbname]
	local indexkeys = do_redis({ "keys", tbname .. ":index:*" })
	local keys = {}
	for _, indexkey in pairs(indexkeys) do
		local ids = do_redis({ "zrange", indexkey, 0, -1 })
		for _, id in pairs(ids) do
			table.insert(keys ,tbname .. ":" .. id)
		end
	end

	if table.empty(keys) then
		keys = do_redis({ "keys", tbname .. ":*" })
	end

	for _, v in pairs(keys) do
		if v ~= tbname..":"..schema[tbname]["pk"] then
			local row = do_redis({ "hgetall", v })

			row = make_pairs_table(row)
			row = convert_record(tbname, row)

			local key = make_rediskey(row, config.key)
			data[key] = row
		end
	end

	return data
end

function CMD.get_schema(tbname)
	return schema[tbname]
end

-- 加user类型表单行数据到redis
function CMD.load_user_single(tbname, uid)
	local config = user_table[tbname]
	local data = load_data_impl(config, uid)

	assert(#data <= 1)
	if #data == 1 then
		return data[1]
	end

	return data			-- 这里返回的一定是空表{}
end

-- 加user类型表多行数据到redis
function CMD.load_user_multi(tbname, uid)
	local config = user_table[tbname]
	local data = {}
	local t = load_data_impl(config, uid)

	local pk = schema[tbname]["pk"]
	for k, v in pairs(t) do
		data[v[pk]] = v
	end

	return data
end

function CMD.hmset(uid, key, t)
	local data = {}
	for k, v in pairs(t) do
		table.insert(data, k)
		table.insert(data, v)
	end

	local db = getconn(uid)
	db:hmset(key, table.unpack(data))

	return true
end

-- 从redis获取user类型表单行数据，如果不存在，则从mysql加载
-- fields为空，获取整行
function CMD.get_user_single(tbname, uid, fields)
	local result
	if fields then
		result = do_redis({ "hmget", tbname .. ":" .. uid, table.unpack(fields) }, uid)
		result = make_pairs_table(result, fields)
	else
		result = do_redis({ "hgetall", tbname .. ":" .. uid }, uid)
		result = make_pairs_table(result)
	end

	-- redis没有数据返回，则从mysql加载
	if table.empty(result) then
		local t = CMD.load_user_single(tbname, uid)
		if fields and not table.empty(t) then
			result = {}
			for k, v in pairs(fields) do
				result[v] = t[v]
			end
		else
			result = t
		end
	end

	result = convert_record(tbname, result)

	return result
end

-- 从redis获取user类型表多行数据，如果不存在，则从mysql加载
function CMD.get_user_multi(tbname, uid, id, fields)
	local result
	local ids = do_redis({ "zrange", tbname .. ":index:" .. uid, 0, -1 }, uid)

	local pk = schema[tbname]["pk"]
	if table.empty(ids) then
		local t = CMD.load_user_multi(tbname, uid)

		if id then
			if fields then
				result = {}
				for k, v in pairs(fields) do
					result[v] = t[id][v]
				end
			else
				result = t[id] or {}
			end
		else
			if fields then
				result = {}
				for k, v in pairs(t) do
					result[k] = {}
					setmetatable(result, { __mode = "k" })

					for i=1, #fields do
						result[k][fields[i]] = t[k][fields[i]]
					end
				end
			else
				result = t
			end

			for _, id in pairs(ids) do
				local t = do_redis({ "hgetall", tbname .. ":" .. id }, uid)
				t = make_pairs_table(t)
				t = convert_record(tbname, t)
				result[tonumber(id)] = t
			end
		end
	else
		if id then
			if fields then
				result = do_redis({ "hmget", tbname .. ":" .. id, table.unpack(fields) }, uid)
				result = make_pairs_table(result,fields)
			else
				result = do_redis({ "hgetall", tbname .. ":" .. id }, uid)
				result = make_pairs_table(result)
			end
			
		else
			result = {}
			for _, id in pairs(ids) do
				local t = do_redis({ "hgetall", tbname .. ":" .. id }, uid)
				t = make_pairs_table(t)
				t = convert_record(tbname, t)
				result[tonumber(id)] = t
			end
		end
	end

	return result
end

-- redis中增加一行记录，并同步到mysql
function CMD.add(tbname, row, type, nosync)

	local config 
	if type == 1 then
		config = config_table[tbname]
	elseif type == 2 then
		config = user_table[tbname]
	elseif type == 3 then
		config = common_table[tbname]
	end

	local uid
	if row.uid and type == 2 then
		uid = row.uid
	end
	
	local key = config.key
	local indexkey = config.indexkey
	local rediskey = make_rediskey(row, key)
	do_redis({ "hmset", tbname .. ":" .. rediskey, row }, uid)
	if indexkey then
		local linkey = make_rediskey(row,indexkey)
		do_redis({ "zadd", tbname..":index:"..linkey, 0, rediskey }, uid)
	end

	if not nosync then
		local columns
		local values
		for k, v in pairs(row) do
			if not columns then
				columns = k
			else
				columns = columns .. "," .. k
			end
			
			if not values then
				values = "'" .. v .. "'"
			else
				values = values .. "," .. "'" .. v .. "'"
			end
		end

		local sql = "insert into " .. tbname .. "(" .. columns .. ") values(" .. values .. ")"
		skynet.call("dbsync", "lua", "sync", sql)
	end

	return true
end

-- redis中删除一行记录，并同步到mysql
function CMD.delete(tbname, row, type, nosync)
	local config 
	if type == 1 then
		config = config_table[tbname]
	elseif type == 2 then
		config = user_table[tbname]
	elseif type == 3 then
		config = common_table[tbname]
	end

	local uid
	if row.uid and type == 2 then
		uid = row.uid
	end

	local key = config.key
	local indexkey = config.indexkey
	local rediskey = make_rediskey(row, key)
	local pk = schema[tbname]["pk"]

	do_redis({ "del", tbname .. ":" .. rediskey }, uid)
	if indexkey then
		local linkey = make_rediskey(row,indexkey)
		do_redis({ "zrem", tbname .. ":index:" .. linkey }, uid)
	end

	if not nosync then
		local sql = "delete from " .. tbname.. " where " .. pk .. "=" .. "'" .. row[pk] .. "'"
		skynet.call("dbsync", "lua", "sync", sql)
	end

	return true

end

-- redis中更新一行记录，并同步到mysql
function CMD.update(tbname, row, type, nosync)
	local config 
	if type == 1 then
		config = config_table[tbname]
	elseif type == 2 then
		config = user_table[tbname]
	elseif type == 3 then
		config = common_table[tbname]
	end

	local uid
	if row.uid and type == 2 then
		uid = row.uid
	end

	local key = config.key
	local rediskey = make_rediskey(row, key)

	do_redis({ "hmset", tbname .. ":" .. rediskey, row }, uid)

	if not nosync then
		local setvalues = ""

		for k, v in pairs(row) do
			setvalues = setvalues .. k .. "='" .. v .. "',"
		end

		setvalues = setvalues:trim(",")

		local pk = schema[tbname]["pk"]
		local sql = "update " .. tbname .. " set " .. setvalues .. " where " .. pk .. "='" .. row[pk] .. "'"

		skynet.call("dbsync", "lua", "sync", sql)
	end

	return true
end

function CMD.get_table_key(tbname, type)
	local t
	if type == 1 then
		t = config_table
	elseif type == 2 then
		t = user_table
	elseif type == 3 then
		t = common_table
	end

	return schema[tbname]["pk"], t[tbname].key, t[tbname].indexkey
end

function CMD.refresh_cache( )
	load_config_data()
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(SERVICE_NAME)
end)
