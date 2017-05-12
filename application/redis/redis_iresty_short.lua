--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Author: Tinywan
* |  Date: 2017/5/8 16:25
* |  Mail: Overcome.wan@Gmail.com
* |------------------------------------------------------------------------
* |  version: 1.0
* |  description: redis_iresty 短连接测试
* |------------------------------------------------------------------------
--]]
local redis = require "resty.redis_iresty"
local red = redis:new()

local res, err = red:auth("tinywan123456")
if not res then
    ngx.say("failed to authenticate: ", err)
    return
end

local ok, err = red:set("OPenresty_short", "NGINX-based OPenresty_short")
if not ok then
    ngx.say("failed to set: ", err)
    return
end

ngx.say("set result: ", ok)
