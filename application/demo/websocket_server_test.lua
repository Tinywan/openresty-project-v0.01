local server = require "resty.websocket.server"
local shell = require 'vendor.websocket_shell'  -- 注意这里是怎么引入第三方自定义文件的
local json = require 'cjson'

-- 在服务器端执行websocket握手过程，并返回WebSocket服务器对象,如果出现错误，它返回nil一个描述错误的字符串
local wb, err = server:new{
    timeout = 5000,  -- in milliseconds
    max_payload_len = 65535,
}
-- 如果 WebSocket服务器对象 不存在
if not wb then
    ngx.log(ngx.ERR, "failed to new websocket: ", err)
    return ngx.exit(444)
end

--[[
[1]接收一个WebSocket,在出现错误的情况下，返回两个nil值和描述错误的字符串
[2] 第二个值(type)返回值始终是帧类型,值可以是：continuation，text，binary，close，ping，pong，或nil（对于未知的类型）
[3] 如果type = close 帧，返回3个值
    1.额外的状态消息（可以是空字符串）
    2.字符串“close”
    3.状态代码（如果有的话）
    -- ]]
local data, typ, err = wb:recv_frame()

if not data then
    ngx.log(ngx.ERR, "failed to receive a frame: ", err)
    return ngx.exit(444)
end

if typ == "close" then
    -- send a close frame back:

    local bytes, err = wb:send_close(1000, "enough, enough!")
    if not bytes then
        ngx.log(ngx.ERR, "failed to send the close frame: ", err)
        return
    end
    local code = err
    ngx.log(ngx.INFO, "closing with status code ", code, " and message ", data)
    return
end

if typ == "ping" then
    -- send a pong frame back:

    local bytes, err = wb:send_pong(data)
    if not bytes then
        ngx.log(ngx.ERR, "failed to send frame: ", err)
        return
    end
elseif typ == "pong" then
    -- just discard the incoming pong frame

else
    ngx.log(ngx.INFO, "received a frame of type ", typ, " and payload ", data)
end

local res = shell.vmstat()
if res then
    res.time = ngx.time()
    local data = json.encode(res)
    bytes, err = wb:send_text(data)
    if not bytes then
        ngx.log(ngx.ERR, "failed to send a text frame: ", err)
        return ngx.exit(444)
    end
end


local bytes, err = wb:send_close(1000, "enough, enough!")
if not bytes then
    ngx.log(ngx.ERR, "failed to send the close frame: ", err)
    return
end
