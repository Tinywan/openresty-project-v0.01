--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/6/15 23:25
* |  Function: To change this template use File | Settings | File Templates.
* |  Openresty 模板渲染界面
* |------------------------------------------------------------------------
--]]
local server = require "resty.websocket.server"
local helper = require "vendor.helper"
local wb, err = server:new {
    timeout = 5000,
    max_payload_len = 65535
}
if not wb then
    ngx.log(ngx.ERR, "failed to new websocket: ", err)
    return ngx.exit(444)
end
while true do
    local data, typ, err = wb:recv_frame()
    if wb.fatal then
        ngx.log(ngx.ERR, "failed to receive frame: ", err)
        return ngx.exit(444)
    end
    if not data then
        local bytes, err = wb:send_ping()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send ping: ", err)
            return ngx.exit(444)
        end
    elseif typ == "close" then break
    elseif typ == "ping" then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send pong: ", err)
            return ngx.exit(444)
        end
    elseif typ == "pong" then
        ngx.log(ngx.INFO, "client ponged")
    elseif typ == "text" then
        local bytes, err = wb:send_text('['..ngx.localtime()..'] say : '..data)
--        local send_data =
        ngx.log(ngx.ERR, "wb:send_text: ", '['..ngx.localtime()..'] say : '..data)
        if not bytes then
            ngx.log(ngx.ERR, "failed to send text: ", err)
            return ngx.exit(444)
        end
    end
end

wb:send_close()

