--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/6/19
-- Time: 10:05
-- To change this template use File | Settings | File Templates.
--
local redis = require "resty.redis"
local log = ngx.log
local redis_host = "121.41.88.209"
local redis_port = "63789"
local redis_auth = "tinywanredisamaistream"
local redis_timeout = 1000

local red = redis:new()
red:set_timeout(5000) -- 1 sec
local ok, err = red:connect(redis_host, redis_port)
if not ok then
    ngx.log(ngx.ERR, "failed to connect redis: ", err)
    wb:send_close()
    return
end

ok, err = red:auth(redis_auth)
if not ok then
    log(ERR, "failed to auth: ", err)
end

resp, err = red:set("LATEST_COMMENT::12345", "LATEST_COMMENT VALUES")
if not resp then
    ngx.log(ngx.ERR, "set redis live error : ", err)
end

