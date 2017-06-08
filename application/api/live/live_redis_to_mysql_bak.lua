--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/5/25 22:29
* |  Function: API接口先查询Redis缓存数据，如果没有则到Mysql 数据库获取同时缓存下来，同时把数据在模板页面显示出来
* |------------------------------------------------------------------------
--]]
local redis = require("resty.redis")
local mysql = require "resty.mysql"
local cjson = require("cjson")
local helper = require 'vendor.helper'
local cjson_encode = cjson.encode
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_exit = ngx.exit
local ngx_print = ngx.print
local ngx_re_match = ngx.re.match
local ngx_var = ngx.var
local get_var = ngx.req.get_uri_args()

-- close redis
local function close_redis(red)
    if not red then
        return
    end
    --释放连接(连接池实现)
    local pool_max_idle_time = 10000 --毫秒
    local pool_size = 100 --连接池大小
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)

    if not ok then
        ngx_log(ngx_ERR, "set redis keepalive error : ", err)
    end
end

-- read redis
local function read_redis(id)
    local red = redis:new()
    red:set_timeout(1000)
    local ip = "127.0.0.1"
    local port = 63700
    local auth = "tinywan123456"
    local ok, err = red:connect(ip, port)
    if not ok then
        ngx_log(ngx_ERR, "connect to redis error : ", err)
        return close_redis(red)
    end

    local res, err = red:auth(auth)
    if not res then
        ngx.say("failed to authenticate: ", err)
        return
    end

    local resp, err = red:get("LiveTable:"..id)
    if not resp then
        ngx_log(ngx_ERR, "get redis content error : ", err)
        return close_redis(red)
    end
    --得到的数据为空处理
    if resp == ngx.null then
        resp = nil
    end
    close_redis(red)
--    resp = {data = 'Content comes from Redis '}
    return resp
end

-- read backend
local function read_http(id)
    local resp = ngx.location.capture("/sub", {
        method = ngx.HTTP_GET,
        args = {id = id}
    })

    if not resp then
        ngx_log(ngx_ERR, "mysql request error :", err)
        return
    end

    -- 判断状态码
    if resp.status ~= ngx.HTTP_OK then
        ngx_log(ngx_ERR, "request error, status :", resp.status)
        return
    end

    if resp.status == ngx.HTTP_FORBIDDEN then
        ngx.exit(resp.status)
    end

    -- 获取后端Mysql数据存储到Redis中去
    local red = redis:new()
    red:set_timeout(1000)
    local ip = "127.0.0.1"
    local port = 63700
    local auth = "tinywan123456"
    local ok, err = red:connect(ip, port)
    if not ok then
        ngx_log(ngx_ERR, "connect to redis error : ", err)
        return close_redis(red)
    end

    local res, err = red:auth(auth)
    if not res then
        ngx.say("failed to authenticate: ", err)
        return
    end
    local ok, err = red:set(id,cjson.encode('Redis Cache Content '..id))
    if not ok then
        ngx_log(ngx_ERR, "failed to set : " .. id, err)
    end
    return resp.body
end

-- read mysql
local function read_mysql(id)
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

    -- Mysql查询结果 -- array table
    mysql_res, err, errcode, sqlstate = db:query("select * from tb_ngx_test where id = "..id, 10)
    if not mysql_res then
        ngx_log(ngx_ERR, "Mysql select fail: ", err)
        return nil
    end

    -- 获取后端Mysql数据存储到Redis中去
    local red = redis:new()
    red:set_timeout(1000)
    local ip = "127.0.0.1"
    local port = 63700
    local auth = "tinywan123456"
    local ok, err = red:connect(ip, port)
    if not ok then
        ngx_log(ngx_ERR, "connect to redis error : ", err)
        return close_redis(red)
    end

    local res, err = red:auth(auth)
    if not res then
        ngx_log(ngx_ERR, "failed to authenticate: ", err)
        return
    end

    -- 为了方便测试，给该数组添加一个字段 data = "Redis Cache Content"
    mysql_res['Data_Sources'] = "Redis Cache Content"
    local ok, err = red:set("LiveTable:"..id,cjson.encode(mysql_res))
    -- save redis result ： "{\"1\":{\"age\":\"24\",\"name\":\"tinywan\",\"address\":\"China\",\"id\":\"3\"},\"Data_Sources\":\"Redis Cache Content\"}"
    if not ok then
        ngx_log(ngx_ERR, "failed to set : " .. id, err)
    end
    -- 为了方便，这里全部转换成json格式返回
    return cjson.encode(mysql_res)
end


--获取id
local id = get_var.id

--从redis获取数据
local content = read_redis(id)

--如果redis没有，回源到后端的 mysql 数据库
if not content then
    ngx_log(ngx_ERR, "redis not cache content, Content comes from mysql , id : ", id)
    content = read_mysql(id)
--    content = read_http(id)
else
    ngx_log(ngx_ERR, "Content comes from Redis, id = ", id)
end

--如果还没有返回404
if not content then
    ngx_log(ngx_ERR, "http not found content, id : ", id)
    return ngx_exit(ngx.HTTP_NOT_FOUND)
end

-- 返回数据为json格式，直接输出就可以了
ngx_print(content.."\n")

