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

local mysql = require 'vendor.mysql_fun'
local cjson = require 'cjson'
data = { name = "TinyWAN", address = "HeilongJiang", age = "26" }
local result = mysql.add(data.name,data.address,data.age)
ngx.print(cjson.encode(result))




