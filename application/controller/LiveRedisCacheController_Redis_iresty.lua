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
--local redis = require("resty.redis")
local redis = require "resty.redis_iresty"
local cjson = require("cjson")
local cjson_encode = cjson.encode
local cjson_decode = cjson.decode
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_exit = ngx.exit
local ngx_print = ngx.print
local ngx_re_match = ngx.re.match
local ngx_var = ngx.var

-- read redis
local function read_redis(auth, keys)
    local red = redis:new()
    -- Redis授权登陆
    local res, err = red:auth(auth)
    if not res then
        ngx_log(ngx_ERR, "failed to authenticate ", err)
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
        ngx_log(ngx_ERR, "get redis content error : ", err)
        return
    end

    --得到的数据为空处理
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
        ngx_log(ngx_ERR, "failed to authenticate: ", err)
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
        ngx_log(ngx_ERR, "set redis live error : ", err)
        return
    end
    return resp
end

-- read mysql
local function read_http(id)
    local resp = ngx.location.capture("/openapi/luaJson", {
        method = ngx.HTTP_GET,
        args = { id = id }
    })

    if not resp then
        ngx_log(ngx_ERR, "API request error :", err)
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

    -- Redis 数据缓存
    local live_info_key = "LIVE_TABLE:" .. id
    local live_value = cjson_decode(resp.body) -- 解析的Lua自己的然后存储到Redis 数据库中去
    local live_live_str = write_redis('tinywanredisamaistream', { live_info_key }, cjson_encode(live_value))
    if not live_live_str then
        ngx_log(ngx_ERR, "redis set info error: ")
    end

    return cjson_encode(live_value)
end


--获取id
local id = ngx_var.id

--从redis获取
local live_info_key = "LIVE_TABLE:" .. id
local content = read_redis('tinywanredisamaistream', { live_info_key })

--如果redis没有，回源到tomcat mysql 数据库
if not content then
    ngx_log(ngx_ERR, "redis not found content, back to backend API , id : ", id)
    content = read_http(id)
end

-- 如果还没有返回404 这里以后要做优化
if not content then
    ngx_log(ngx_ERR, "backend API not found content, id : ", id)
    return ngx_exit(ngx.HTTP_NOT_FOUND)
end
--输出内容
--ngx_print(cjson_encode({ content = content }))
members = { Tom = 10, Jake = 11, Dodo = 12, Jhon = 16 }
template.render("index.html", {title = "Openresty 模板渲染界面",content = cjson_decode(content),members = members})