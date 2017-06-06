--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Author: Tinywan
* |  Date: 2017/5/8 16:25
* |  Mail: Overcome.wan@Gmail.com
* |------------------------------------------------------------------------
* |  version: 1.0
* |  description: redis 长连接带连接池测试
* |------------------------------------------------------------------------
--]]
local redis = require("resty.redis")
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR

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

local function read_redis(ip, port,auth,keys)
    local red = redis:new()
    red:set_timeout(1000)
    -- connect
    local ok, err = red:connect(ip, port)
    if not ok then
        ngx_log(ngx_ERR, "connect to redis error : ", err)
        return close_redis(red)
    end

    -- Redis授权登陆
    local count
    count, err = red:get_reused_times()
    if 0 == count then
        local res, err = red:auth(auth)
        if not res then
            ngx_log(ngx_ERR, "failed to authenticate: ", err)
            return
        end
    elseif err then
        ngx_log(ngx_ERR, "failed to get_reused_times: ", err)
    end

    -- get data
    local resp = nil
    if #keys == 1 then
        resp, err = red:get(keys[1])
    else
        resp, err = red:mget(keys)
    end
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

local function read_http(args)
    local resp = ngx.location.capture("/backend/info", {
        method = ngx.HTTP_GET,
        args = args
    })

    if not resp then
        ngx_log(ngx_ERR, "request error")
        return
    end
    if resp.status ~= 200 then
        ngx_log(ngx_ERR, "request error, status :", resp.status)
        return
    end
    return resp.body
end

local _M = {
    read_redis = read_redis,
    read_http = read_http
}
return _M


