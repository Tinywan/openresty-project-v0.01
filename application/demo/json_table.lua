--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/6/11
-- Time: 10:53
-- To change this template use File | Settings | File Templates.
--  json 和 lua table 转换的细节

local helper = require "vendor.helper"
local json = require "cjson"

local function format_table(t)
    local str = ""
    for k, v in pairs(t) do
        str = str..k..'--'..v.."\r\n"
    end
    return str
end

---- [1]将json 转换成lua table
--local json_str = '{"is_male":"nan","name":"zhangsan","id":1}'
--local t = json.decode(json_str)
--ngx.say(format_table(t))
----
---- [2]将lua table转换成json 字符串
--local t = [[{key="table key",value="table value"}]]
--local json_str = json.encode(t)
--ngx.say(json_str) -- "{key=\"table key\",value=\"table value\"}"
--
---- [3]将lua table转换成 json 数组  lua 两个大括号表示一个数组
local t = {keys={"list1","list2","list3"},num=1}
local str = json.encode(t)
ngx.say(str)

--local str_error_json = '{"key":"this is key","value":"this is value"}'
local str_error_json = [[{"key":"this is key","value":"this is value"}]]
--local json_str = json.decode(str_error_json)
--ngx.say(json_str)

--local function json_decode(str)
--    local json_val = nil
--    pcall(function(str) json_val = json.decode(str) end,str)
--    return json_val
--end
local json_str = helper.cjson_decode(str_error_json)
if not json_str then
    ngx.say('cjson_decode error')
else
    ngx.say("cjson_decode success")
    ngx.say(format_table(json_str))
end
