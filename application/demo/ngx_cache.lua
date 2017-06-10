--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/6/10
-- Time: 21:26
-- To change this template use File | Settings | File Templates.
--
local live_ngx_cache = ngx.shared.live_ngx_cache;

function set_cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end
    local succ, err, forcible = live_ngx_cache:set(key, value, exptime)
    return succ
end

function get_cache(key)
    local value = live_ngx_cache:get(key)
    if not value then
--        value = get_from_redis(key)
--        set_cache(key, value)
--        return value
        return nil
    end
    ngx.say("get from live_ngx_cache.")
    return value
end

local res = get_cache('name')
ngx.say(res)

