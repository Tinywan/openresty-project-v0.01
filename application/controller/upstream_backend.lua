--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/5/26
-- Time: 22:56
-- To change this template use File | Settings | File Templates.
--
local redis = require "resty.redis_iresty"
local cjson = require "cjson"
local red = redis:new()

local args = ngx.req.get_uri_args()
local uri = ngx.var.request_uri
ngx.say('uri == '..uri)

local callid = nil
local channel = 0

if string.find(uri, 'yuntongxun') then
    callid = args["callid"]
    channel = 0
elseif string.find(uri, 'yunhu') then
    ngx.req.read_body()
    local body_data = ngx.req.get_body_data()
    local data = cjson.decode(body_data)
    callid = data['call_id']
    channel = 1
elseif string.find(uri, 'huawei') then
    callid = args["vSessionsId"]
    channel = 2
else
end

if callid == nil then
    ngx.say(uri)
    ngx.say(cjson.encode(args))
    ngx.say('callid is empty')
    return ''
end


local key = callid .. '_channel' .. channel
local res = red:get(key)
if res == ngx.null then
    ngx.say("cache get error")
    return ''
end

ngx.var.backend = res

