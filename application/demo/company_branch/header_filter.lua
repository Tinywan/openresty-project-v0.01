--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/6/19
-- Time: 10:14
-- To change this template use File | Settings | File Templates.
--
local match = string.match

local function get_cookies()
    -- local cookies = ngx.header["Set-Cookie"] or {}
    local cookies = ngx.header.set_cookie or {}
    if type(cookies) == "string" then
        cookies = {cookies}
    end
    return cookies
end

local function remove_cookie(cookie_name)
    local cookies = get_cookies()

    ngx.log(ngx.ERR, "source cookies ", table.concat(cookies, " "))
    for key, value in ipairs(cookies) do
        local name = match(value, "(.-)=")
        ngx.log(ngx.ERR, key.."<=>", value)
        if name == cookie_name then
            table.remove(cookies, key)
        end
    end

    ngx.header['Set-Cookie'] = cookies or {}
    ngx.log(ngx.ERR, "new cookies ", table.concat(cookies, " "))
end

remove_cookie("Foo")