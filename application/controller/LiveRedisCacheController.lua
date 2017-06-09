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
local template = require "resty.template"
local redis = require "resty.redis_iresty"
local cjson = require("cjson")
local http = require("resty.http")
local cjson_encode = cjson.encode
local cjson_decode = cjson.decode
local log = ngx.log
local ERR = ngx.ERR
local exit = ngx.exit
local ngx_var = ngx.var
local print = ngx.print

-- read redis
local function read_redis(auth, keys)
    local red = redis:new()
    -- Redis授权登陆
    local res, err = red:auth(auth)
    if not res then
        --log(DEBUG, "query the TCP server due to reply truncation")
        log(ERR, "failed to authenticate ", err)
        return
    end

    -- get data
    local resp = nil
    if #keys == 1 then
        resp, err = red:get(keys[1])
    else
        resp, err = red:mget(keys)
    end

    if not resp then
        log(ERR, "get redis content error : " .. keys[1], err)
        return
    end

    if resp == ngx.null then
        resp = nil
    end

    return resp
end

-- 主要是后端数据缓存处理
local function write_redis(auth, keys, values)
    local red = redis:new()
    -- Redis授权登陆
    local res, err = red:auth(auth)
    if not res then
        log(ERR, "failed to authenticate: ", err)
        return
    end

    -- set data
    local resp = nil
    if #keys == 1 then
        resp, err = red:set(keys[1], values)
    else
        resp, err = red:mset(keys, values)
    end
    if not resp then
        log(ERR, "set redis live error : ", err)
        return
    end
    return resp
end

-- 大并发采用 resty.http ，对于：ngx.location.capture 慎用
local function read_http(id)
    local httpc = http.new()
    local resp, err = httpc:request_uri("http://sewise.www.com", {
        method = "GET",
        path = "/openapi/luaJson?id=" .. id,
        headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36"
        }
    })

    if not resp then
        log(ERR, "resty.http API request error :", err)
        return
    end
    httpc:close()

    -- 判断状态码
    if resp.status ~= ngx.HTTP_OK then
        log(ERR, "request error, status :", resp.status)
        return
    end

    if resp.status == ngx.HTTP_FORBIDDEN then
        log(ERR, "request error, status :", resp.status)
        return
    end

    -- Redis 数据缓存
    local live_info_key = "LIVE_TABLE:" .. id
    local live_value = cjson_decode(resp.body) -- 解析的Lua自己的然后存储到Redis 数据库中去
    local live_live_str = write_redis('tinywanredisamaistream', { live_info_key }, cjson_encode(live_value))
    if not live_live_str then
        log(ERR, "redis set info error: ")
    end

    return cjson_encode(live_value)
end


--获取id
local id = ngx_var.id

--redis get content
local live_info_key = "LIVE_TABLE:" .. id
local content = read_redis('tinywanredisamaistream', { live_info_key })

--if redis not request backend API
if not content then
    log(ERR, "redis not found content, back to backend API , id : ", id)
    content = read_http(id)
end

-- if backend API  not exit 404
if not content then
    log(ERR, "backend API not found content, id : ", id)
    return ngx.exit(ngx.HTTP_NOT_FOUND)
end

-- if backend API  response result is false 403
if tostring(content) == "false" then
    log(ERR, "backend API content is false ", id)
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end

members = { Tom = 10, Jake = 11, Dodo = 12, Jhon = 16 }
template.caching(true)
template.render("index.html", { title = "Openresty 模板渲染界面", content = cjson_decode(content), members = members })