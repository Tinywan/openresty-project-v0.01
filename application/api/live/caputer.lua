--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/5/25
-- Time: 20:54
-- To change this template use File | Settings | File Templates.
--
--ngx.ctx.blah = 73
--ngx.say("main pre: ", ngx.ctx.blah)
--local res = ngx.location.capture("/sub")
--ngx.print(res.body)
--ngx.say("main post: ", ngx.ctx.blah)
local id = 123
local resp = ngx.location.capture("/sub", {
    method = ngx.HTTP_GET,
    args = { id = id}

})

if not resp then
    ngx.say("request error :", err)
    return
end
ngx.log(ngx.ERR, tostring(resp.status))

--获取状态码
ngx.say(resp.status) -- 200
ngx.status = resp.status

--获取响应头
for k, v in pairs(resp.header) do
    if k ~= "Transfer-Encoding" and k ~= "Connection" then
        ngx.header[k] = v
    end
end
ngx.say('header')
--响应体
if resp.body then
    ngx.say('resp.body == '..resp.body)
end

