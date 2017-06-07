--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/5/19 23:25
* |  Function: To change this template use File | Settings | File Templates.
* |------------------------------------------------------------------------
--]]

--加载Lua模块库
local dkjson = require 'vendor.dkjson'
local redis = require "resty.redis_iresty"
local template = require("resty.template")

local red = redis:new()
local res, err = red:auth("tinywan123456")
if not res then
    ngx.say("failed to authenticate: ", err)
    return
end

-- get redis data
local res, err = red:get("2017TinywanInfo")
if not res then
    ngx.say("failed to get decode_redis: ", err)
    return
end

if res == ngx.null then
    ngx.say("decode_redis not found.")
    return
end

local obj, pos, err = dkjson.decode(res, 1, nil)

--ngx.say(obj.Personal['name'], "<br/>")
--ngx.say(obj.Personal['age'], "<br/>")
--ngx.say(obj.Personal['max'], "<br/>")
--ngx.say(obj.GitHub, "<br/>")

--渲染模板
template.render("chatroom.html",obj)




