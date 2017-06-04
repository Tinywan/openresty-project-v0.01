--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/6/02 22:29
* |  Function: msyql add select udpate delete option
* |------------------------------------------------------------------------
--]]
--local mysql = require 'vendor.mysql_fun'
--local cjson = require 'cjson'
--ngx.say("_VERSION == "..mysql._VERSION)
--  local result = mysql.update(5,"Tinywan Github")
----  local result = mysql.select(5)
--  ngx.print(cjson.encode(result))
--ngx.say(result)

--local mysql = require 'vendor.mysql_fun'
--local helper = require 'vendor.helper'
--local cjson = require 'cjson'
--local args = helper.http_args()
--ngx.say(args.id)
--ngx.say(args.name)
--local result = mysql.select(15)
--ngx.print(cjson.encode(result))

local mysql = require 'vendor.mysql_fun'
local cjson = require 'cjson'
data = { name = "TinyWAN", address = "http://ivi.bupt.edu.cn/hls/cctv5hd.m3u8", age = "26" }
local result = mysql.add(data.name,data.address,data.age)
ngx.print(cjson.encode(result))




