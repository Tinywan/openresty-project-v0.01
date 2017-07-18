--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/5/19 23:25
* |  Function: local_live_test.
* |  TestInfo: port = 63700 auth = tinywan123456
* |  log [n] 这样子的log日志是可以删除的（）
* |------------------------------------------------------------------------
--]]
local template = require "resty.template"
local helper = require "vendor.helper"
local redis = require "resty.redis"
local resty_lock = require "resty.lock"
local http = require "resty.http"
local log = ngx.log
local ERR = ngx.ERR
local exit = ngx.exit
local ngx_var = ngx.var
local print = ngx.print
local live_ngx_cache = ngx.shared.live_ngx_cache
local live_room = ngx.shared.live_room
-- 非error 日志开关 1:开启，0:关闭
local log_switch = 1

local redis_host = "121.41.88.209"
local redis_port = 63789
local redis_auth = "tinywanredisamaistream123456789"
local redis_timeout = 1000

-- set ngx.cache
local function set_cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end
    local succ, err, forcible = live_ngx_cache:set(key, value, exptime)
    return succ
end

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
        log(ERR, "set redis keepalive error : ", err)
    end
end

-- read redis
local function read_redis(_host, _port, _auth, keys)
    local red = redis:new()
    red:set_timeout(redis_timeout)
    local ok, err = red:connect(_host, _port)
    if not ok then
        log(ERR, "connect to redis error : ", err)
    end

    -- 请注意这里 auth 的调用过程
    local count
    count, err = red:get_reused_times()
    if 0 == count then
        ok, err = red:auth(_auth)
        if not ok then
            log(ERR, "failed to auth: ", err)
            return close_redis(red)
        end
    elseif err then
        log(ERR, "failed to get reused times: ", err)
        return close_redis(red)
    end

    local resp = nil
    if #keys == 1 then
        resp, err = red:get(keys[1])
    else
        resp, err = red:mget(keys)
    end

    if not resp then
        log(ERR, keys[1] .. " get redis content error : ", err)
        return close_redis(red)
    end

    if resp == ngx.null then
        resp = nil
    end
    close_redis(red)
    -- [1] del log
    if log_switch == 1 then
        log(ERR, "[2] [read_redis] content from redis.cache  id = " .. keys[1]) -- tag data origin
    end
    return resp
end

-- write redis
local function write_redis(_host, _port, _auth, keys, values)
    local red = redis:new()
    red:set_timeout(redis_timeout)
    local ok, err = red:connect(_host, _port)
    if not ok then
        log(ERR, "connect to redis error : ", err)
    end

    local count
    count, err = red:get_reused_times()
    if 0 == count then
        ok, err = red:auth(_auth)
        if not ok then
            log(ERR, "failed to auth: ", err)
            return close_redis(red)
        end
    elseif err then
        log(ERR, "failed to get reused times: ", err)
        return close_redis(red)
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
        close_redis(red)
    end
    close_redis(red)
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
        if log_switch == 1 then
            log(ERR, " [1] [read_ngx_cache]  content from ngx.cache id = " .. key) -- tag data origin
        end
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
    local val = read_redis(redis_host, redis_port, redis_auth, { key })
    if not val then
        local ok, err = lock:unlock()
        if not ok then
            log(ERR, "failed to unlock [222] : ", err)
        end
        -- FIXME: we should handle the backend miss more carefully
        -- here, like inserting a stub value into the cache.
        log(ERR, "[4] ngx.cache find redis cache no value found : ", err)
        return ngx_resp
    end

    -- [lock] update the shm cache with the newly fetched value
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
    local resp, err = httpc:request_uri("http://testwww.amai9.com", {
        method = "GET",
        path = "/api/liveBackToSourceApi?liveId=" .. id,
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

    -- backend not data 判断api返回的状态码
    local status_code = helper.cjson_decode(resp.body)['code']
    if tonumber(status_code) == 200 then
        -- 正常数据缓存到 Redis 数据缓存
        local live_info_key = "LIVE_TABLE:" .. id
        local live_value = helper.cjson_decode(resp.body)['data']-- 解析的Lua自己的然后存储到Redis 数据库中去(这里最好使用lua的json格式去写入)
        local live_live_str = write_redis(redis_host, redis_port, redis_auth, { live_info_key }, helper.cjson_encode(live_value))
        if not live_live_str then
            log(ERR, "redis set info error: ")
        end
        if log_switch == 1 then
            log(ERR, "[3] [read_http] content from backend API id : " .. id) -- tag data origin
        end
        return helper.cjson_encode(live_value)
    else
        -- 后端没有数据直接返回 nil
        log(ERR, " [read_http] backend API is not content return error_msg : " ..helper.cjson_decode(resp.body)['msg']) -- tag data origin
        return
    end
end

-- 业务逻辑处理
local function print_html(id)
    local cache_content = nil
    local live_info_key = "LIVE_TABLE:" .. id
    -- get ngx.cache content 这里遇到的坑就是，注意这里传递的自定义的key
    local content = read_cache(live_info_key)

    --if redis not request backend API and udpate redis cache
    if not content then
        log(ERR, "[5] redis not found content, back to backend API , id : ", id)
        content = read_http(id)
    end
    -- if backend API  not success data , page show  backup data
    if not content then
        log(ERR, "backend API not found content, id : ", id)
        return cache_content
    end
    -- if backend API  response result is false page show 403
    if tostring(content) == "false" then
        log(ERR, "backend API content is false ", id)
        return cache_content
    end
    return content
end
-- get var id
local id = ngx_var.id
local content = print_html(id)
-- 在控制条件中除了false和nil 为假，其他值都为真，所以lua认为0和空字符串也是真
if not content or content == nil then
    -- backup data
    template.render("404.html", {
        title = "404 界面",
    })
    exit(200)
end


members = { Tom = 10, Jake = 11, Dodo = 12, Jhon = 16 }
template.caching(true)
template.render("index.html", {
    live_id = id,
    title = "Openresty 渲染 html 界面",
    ws_title = "Openresty 渲染 websocket",
    content = helper.cjson_decode(content),
    members = members
})