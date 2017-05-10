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

-- auth
local count
count, err = red:get_reused_times()
if 0 == count then
    local res, err = red:auth("tinywan123456")
    if not res then
        ngx.say("failed to authenticate: ", err)
        return
    end
elseif err then
    ngx.say("failed to get_reused_times: ", err)
end


ok, err = red:set("dog_test_long", "an animal 222"..ngx.time())
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

local res, err = red:get("dog_test_long")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end

ngx.say("dog_test_long: ", res)

local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end

