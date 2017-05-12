--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Author: Tinywan
* |  Date: 2017/5/8 16:25
* |  Mail: Overcome.wan@Gmail.com
* |------------------------------------------------------------------------
* |  version: 1.0
* |  description: redis 短连接测试
* |------------------------------------------------------------------------
--]]
local redis = require "resty.redis"
local red = redis:new()

--red:set_timeout(1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

local ok, err = red:connect("127.0.0.1", 63700)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local res, err = red:auth("tinywan123456")
if not res then
    ngx.say("failed to authenticate: ", err)
    return
end

ok, err = red:set("redis_test_short", "redis_test_short"..ngx.time())
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("Tinywan redis_test_short set result: ", ok)

local res, err = red:get("redis_test_short")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end

ngx.say("redis_test_short result: ", res)

