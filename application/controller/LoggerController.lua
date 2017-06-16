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
local logger = require "resty.logger.socket"
if not logger.initted() then
    local ok, err = logger.init{
        host = '192.168.18.180',
        port = 1234,
        flush_limit = 1234,
        drop_limit = 5678,
    }
    if not ok then
        ngx.log(ngx.ERR, "failed to initialize the logger: ",
            err)
        return
    end
end
-- construct the custom access log message in
-- the Lua variable "msg"
local msg = "construct the custom access log message in"
local bytes, err = logger.log(msg)
if err then
    ngx.log(ngx.ERR, "failed to log message: ", err)
    return
end




