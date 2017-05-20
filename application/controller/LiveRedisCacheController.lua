--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/5/19 23:25
* |  Function: To change this template use File | Settings | File Templates.
* |  TestInfo: port = 63700 auth = tinywan123456
* |------------------------------------------------------------------------
--]]

local redis = require("resty.redis")
local cjson = require("cjson")
local cjson_encode = cjson.encode
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_exit = ngx.exit
local ngx_print = ngx.print
local ngx_re_match = ngx.re.match
local ngx_var = ngx.var

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

    local resp, err = red:get(id)
    if not resp then
        ngx_log(ngx_ERR, "get redis content error : ", err)
        return close_redis(red)
    end
    --得到的数据为空处理
    if resp == ngx.null then
        resp = nil
    end
    close_redis(red)

    return resp
end

-- read mysql
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

    return resp.body
end


--获取id
local id = ngx_var.id

--从redis获取
local content = read_redis(id)

--如果redis没有，回源到tomcat mysql 数据库
if not content then
    ngx_log(ngx_ERR, "redis not found content, back to http msyql , id : ", id)
    ngx.say('Nginx is no ')
    content = read_http(id)
end

--如果还没有返回404
if not content then
    ngx_log(ngx_ERR, "http not found content, id : ", id)
    return ngx_exit(ngx.HTTP_NOT_FOUND)
end

--输出内容
ngx_print(cjson_encode({content = content}))