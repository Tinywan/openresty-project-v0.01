local redis = require "resty.redis_iresty"
local red = redis:new()

local ok, err = red:set("OPenresty", "NGINX-based Media Streaming Server")
if not ok then
    ngx.say("failed to set: ", err)
    return
end

ngx.say("set result: ", ok)
