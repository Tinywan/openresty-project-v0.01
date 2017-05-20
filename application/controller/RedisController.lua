--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/5/19 23:25
* |  Function: To change this template use File | Settings | File Templates.
* |  TestInfo: port = 63700 auth = tinywan123456
* |------------------------------------------------------------------------
--]]

local dkjson = require 'vendor.dkjson'
local redis = require "resty.redis_iresty"
local red = redis:new()

local res, err = red:auth("tinywan123456")
if not res then
    ngx.say("failed to authenticate: ", err)
    return
end

--lua对象到字符串
local context = {
    Personal = {
        name = '万少波',
        max = 1,
        age = 24
    },
    Education = {
        degree = "本科",
        profession = "计算机科学与技术专业",
        graduation = "2014届",
        English = "CET-4"
    },
    GitHub = "https://github.com/Tinywan",
    Blog = "http://www.cnblogs.com/Tinywan",
    GitBook = "https://www.gitbook.com/Tinywan",
    Video = "https://vodcdn.alicdn.com/oss/taobao-ugc/1dde6e764244406cbe5962b26eee078c/1476754829/video.mp4",
}

local encode_str = dkjson.encode(context, {indent = true})
-- encode_str save redis
local ok, err = red:set("2017TinywanInfo", encode_str)
if not ok then
    ngx.say("failed to set: ", err)
    return
end
ngx.say("set result: ", ok)