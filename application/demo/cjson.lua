--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/5/26
-- Time: 9:01
-- To change this template use File | Settings | File Templates.
--
local helper = require 'vendor.helper'
local str1  = '{"hobby":{"name":"tinywan","age":24,"reader":"AMAI"},"is_male":false}'
--local str2  = [[ {"hobby":{"name":"tinywan","age":24,"reader":"AMAI"},"is_male:false} ]]

local obj_obj = helper.cjson_encode(str1)
if obj_obj == nil
then
    ngx.say('cjson error')
else
    ngx.say('cjson success')
    ngx.say(obj_obj)
end
ngx.say("all finished")

--local json = require("cjson")


--local function _json_decode(str)
--    return json.decode(str)
--end
--
--function cjson_decode( str )
--    local ok, t = pcall(_json_decode, str)
--    if not ok then
--        return nil
--    end
--
--    return t
--end


--local obj_obj = helper.cjson_decode(str1)
--if obj_obj == nil
--    then
--    ngx.say('cjson error')
--else
--    ngx.say(obj_obj.is_male, "<br/>")
--    ngx.say(obj_obj.hobby.name, "<br/>")
--    ngx.say(obj_obj.hobby.age, "<br/>")
--    ngx.say(obj_obj.hobby.reader, "<br/>")
--end
--ngx.say("all finished")
