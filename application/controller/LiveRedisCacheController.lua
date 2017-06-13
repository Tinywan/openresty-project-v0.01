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
local resty_lock = require "resty.lock"
local http = require "resty.http"
local cjson_encode = cjson.encode
local cjson_decode = cjson.decode
local log = ngx.log
local ERR = ngx.ERR
local exit = ngx.exit
local ngx_var = ngx.var
local print = ngx.print
local live_ngx_cache = ngx.shared.live_ngx_cache;

----------------- set ngx.cache
local function set_cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end
    local succ, err, forcible = live_ngx_cache:set(key, value, exptime)
    return succ
end


-- read redis
local function read_redis(auth, keys)
    local red = redis:new()
    -- Redis授权登陆
    local res, err = red:auth(auth)
    if not res then
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
        log(ERR, keys[1] .. " get redis content error : ", err)
        return
    end

    if resp == ngx.null then
        resp = nil
    end
    log(ERR, " [read_redis] content from redis.cache  id = " .. keys[1]) -- tag data origin
    return resp
end

-- write redis
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


-- get ngx.cache
--[1]即使发生其他一些不相关的错误，您也需要尽快解除锁定。
--[2]在释放锁之前，您需要从后端获得的结果更新缓存，以便其他已经等待锁定的线程在获得锁定后才能获得缓存值。
--[3]当后端根本没有返回任何值时，我们应该通过将一些存根值插入缓存来仔细处理。
local function read_cache(key)
    local ngx_resp = nil
    -- 获取共享内存上key对应的值。如果key不存在，或者key已经过期，将会返回nil；如果出现错误，那么将会返回nil以及错误信息。
    -- step 1
    local val, err = live_ngx_cache:get(key)
    if val then
        log(ERR, " [get_cache]  content from ngx.cache id = " .. key) -- tag data origin
        return val
    end

    if err then
        log(ERR, "failed to get key from shm: ", err)
    end

    -- cache miss!
    -- step 2:
    local lock, err = resty_lock:new("cache_lock") -- new resty.lock
    if not lock then
        log(ERR, "failed to create lock [cache_lock] : ", err)
        return
    end

    local elapsed, err = lock:lock(key) -- 锁
    if not elapsed then
        log(ERR, "failed to acquire the lock", err)
        return
    end
    -- lock successfully acquired!

    -- step 3:
    -- someone might have already put the value into the cache ,so we check it here again:
    val, err = live_ngx_cache:get(key)
    if val then
        local ok, err = lock:unlock()
        if not ok then
            log(ERR, "failed to unlock [111] : ", err)
        end
        return val
    end

    --- step 4:
    local val = read_redis('tinywanredisamaistream', { key })
    if not val then
        local ok, err = lock:unlock()
        if not ok then
            log(ERR, "failed to unlock [222] : ", err)
        end
        -- FIXME: we should handle the backend miss more carefully
        -- here, like inserting a stub value into the cache.
        log(ERR, "redis no value found : ", err)
        return ngx_resp
    end

    -- [lock] update the shm cache with the newly fetched value
    -- 在释放锁之前，您需要从后端获得的结果更新缓存，以便其他已经等待锁定的线程在获得锁定后才能获得缓存值
    local ok, err = live_ngx_cache:set(key, val, 1)
    if not ok then
        local ok, err = lock:unlock()
        if not ok then
            log(ERR, "failed to unlock [333] : ", err)
        end
        log(ERR, "failed to update live_ngx_cache:  ", err)
    end

    local ok, err = lock:unlock()
    if not ok then
        log(ERR, "failed to unlock [444] : ", err)
    end

    return val
end

-------------- read_http 大并发采用 resty.http ，对于：ngx.location.capture 慎用
local function read_http(id)
    local httpc = http.new()
    local resp, err = httpc:request_uri("http://sewise.amai8.com", {
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

    -- 缓存到 Redis 数据缓存  -- 这里要做优化
    local live_info_key = "LIVE_TABLE:" .. id
    local live_value = cjson_decode(resp.body) -- 解析的Lua自己的然后存储到Redis 数据库中去
    local live_live_str = write_redis('tinywanredisamaistream', { live_info_key }, cjson_encode(live_value))
    if not live_live_str then
        log(ERR, "redis set info error: ")
    end
    log(ERR, " [read_http] content from backend API id : " .. id) -- tag data origin
    return cjson_encode(live_value)
end

--get var id
local id = ngx_var.id
local live_info_key = "LIVE_TABLE:" .. id

-------- get ngx.cache content
local content = read_cache(live_info_key)

--if redis not request backend API and udpate redis cache
if not content then
    log(ERR, "redis not found content, back to backend API , id : ", id)
    content = read_http(id)
end

--------------------------------主要就是这里要根据后端服务没有数据的情况处理，最好不要出现500错误就可以啦
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
--print(content)
--exit(200)
members = { Tom = 10, Jake = 11, Dodo = 12, Jhon = 16 }
template.caching(true)
template.render("index.html", {
    title = "Openresty 模板渲染界面",
    content = cjson_decode(content),
    members = members,
    jquery  = '<script src="/video-js/video.js"></script>'
})