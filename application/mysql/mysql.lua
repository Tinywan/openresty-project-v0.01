--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Author: Tinywan
* |  Date: 2017/5/8 16:25
* |  Mail: Overcome.wan@Gmail.com
* |------------------------------------------------------------------------
* |  version: 1.0
* |  description: mysql 连接测试
* |------------------------------------------------------------------------
--]]
local mysql = require "resty.mysql"
local cjson = require "cjson"
local db, err = mysql:new()
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
end

db:set_timeout(1000) -- 1 sec

local ok, err, errcode, sqlstate = db:connect{
    host = "127.0.0.1",
    port = 3306,
    database = "lua",
    user = "root",
    password = "123456",
    max_packet_size = 1024 * 1024 }

if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end

ngx.say("connected to mysql.")

local res, err, errcode, sqlstate =
db:query("drop table if exists tb_ngx_test")
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return
end

res, err, errcode, sqlstate =
db:query("create table tb_ngx_test "
        .. "(id serial primary key, "
        .. "name varchar(15),"
        .. "address varchar(115),"
        .. "age varchar(15))")
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return
end

ngx.say("table tb_ngx_test created.")

res, err, errcode, sqlstate =
db:query("insert into tb_ngx_test (name,address,age) "
        .. "values (\'tinywan\',\'China\',24)")
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return
end

ngx.say(res.affected_rows, " rows inserted into table cats ",
    "(last insert id: ", res.insert_id, ")")

-- run a select query, expected about 10 rows in
-- the result set:
--res, err, errcode, sqlstate = db:query("select * from tb_ngx_test order by id asc", 10)
local id = 3
res, err, errcode, sqlstate = db:query("select * from tb_ngx_test where id = " ..id, 10)
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return
end

--ngx.say("result: ", cjson.encode(res))
for k, v in pairs(res) do
    if type(v) == "table" then
        for new_table_index, new_table_value in pairs(v) do
            ngx.say(new_table_index.." = "..new_table_value)
        end
    else
        ngx.say(k,v)
    end
end
--ngx.say("result: ", cjson.encode(res))

-- put it into the connection pool of size 100,
-- with 10 seconds max idle timeout
local ok, err = db:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end