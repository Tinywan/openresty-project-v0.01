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
local redis = require "resty.redis"
local live_room = ngx.shared.live_room
local log = ngx.log
local channel_name, err = live_room:get("chat")
if channel_name then
    log(ngx.ERR, " resty.websocket.server :: ",err) -- tag data origin
end
local redis_host = "127.0.0.1"
local redis_port = 63789
local redis_auth = "tinywanredisamaistream"
local redis_timeout = 1000

local msg_id = 0
local wb, err = server:new {
    timeout = 5000,
    max_payload_len = 65535
}

if not wb then
    ngx.log(ngx.ERR, "failed to new websocket: ", err)
    return ngx.exit(444)
end


local push = function()
    -- --create redis
    local red = redis:new()
    red:set_timeout(redis_timeout) -- 1 sec
    local ok, err = red:connect(redis_host, redis_port)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect redis: ", err)
        wb:send_close()
        return
    end

    ok, err = red:auth(redis_auth)
    if not ok then
        ngx.log(ngx.ERR, "failed to auth: ", err)
        wb:send_close()
    end
    --sub
    local res, err = red:subscribe(channel_name)
    if not res then
        ngx.log(ngx.ERR, "failed to sub redis: ", err)
        wb:send_close()
        return
    end

    -- loop : read from redis
    while true do
        local res, err = red:read_reply()
        if res then
            local item = res[3]
            --local bytes, err = wb:send_text(tostring(msg_id).." "..item)
            local bytes, err = wb:send_text('[ '..tostring(msg_id).." ] "..ngx.localtime().." "..item)
            if not bytes then
                -- better error handling
                ngx.log(ngx.ERR, "failed to send text: ", err)
                return ngx.exit(444)
            end
            msg_id = msg_id + 1
        end
    end
end


local co = ngx.thread.spawn(push)   -- create thread 1

--main loop
while true do
    -- 获取数据
    local data, typ, err = wb:recv_frame()

    -- 如果连接损坏 退出
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
        ngx.log(ngx.ERR, "send ping: ", data)
    elseif typ == "close" then
        break
    elseif typ == "ping" then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send pong: ", err)
            return ngx.exit(444)
        end
    elseif typ == "pong" then
        ngx.log(ngx.ERR, "client ponged")
    elseif typ == "text" then
        --send to redis
        local red2 = redis:new()
        red2:set_timeout(redis_timeout) -- 1 sec
        local ok, err = red2:connect(redis_host, redis_port)
        if not ok then
            ngx.log(ngx.ERR, "failed to connect redis: ", err)
            break
        end
        ok, err = red2:auth(redis_auth)
        if not ok then
            log(ERR, "failed to auth: ", err)
        end

        local res, err = red2:publish(channel_name, data)
        if not res then
            ngx.log(ngx.ERR, "failed to publish redis: ", err)
        end
    end
end

wb:send_close()

ngx.thread.wait(co)