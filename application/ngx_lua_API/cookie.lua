--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/6/16
-- Time: 10:32
-- To change this template use File | Settings | File Templates.
--
local ck = require "resty.cookie"
local cookie, err = ck:new()
if not cookie then
    ngx.log(ngx.ERR, err)
    return
end

-- set one cookie
local ok, err = cookie:set({
    key = "Name", value = "Bob", path = "/",
    domain = "example.com", secure = true, httponly = true,
    expires = "Wed, 09 Jun 2021 10:18:14 GMT", max_age = 50,
    samesite = "Strict", extension = "a4334aebaec"
})
if not ok then
    ngx.log(ngx.ERR, err)
    return
end

-- set another cookie, both cookies will appear in HTTP response
local ok, err = cookie:set({
    key = "live", value = "12312312321",
})
if not ok then
    ngx.log(ngx.ERR, err)
    return
end

ngx.say("http://192.168.18.180:8088/")
ngx.exit(200)
