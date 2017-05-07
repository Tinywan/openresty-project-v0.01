-- /mnt/hgfs/Linux-Share/Lua/Lua_project_v.01/application/ip_location.lua

ngx.req.read_body()
ngx.header.content_type = "application/json;charset=UTF-8"

local cjson = require "cjson"

-- success fun 
local success = function(con)
    return cjson.encode({
        success = true,
        body = con
    })
end

-- fail fun
local failure = function(err)
    return cjson.encode({
        success = false,
        errors = err
    })
end

-- get var
local get_args = ngx.req.get_uri_args()
local ip_address = get_args.ip

-- 如果不需要验证可以不用此拓展
local checkIp = require("vendor.ip_check"):new(ip_address)

-- validation ip
local ok, err = checkIp:checkIp()
if not ok then
    ngx.say(failure(err))
    return
end

-- use location database
local ipdetail, err = require("vendor.ip_location"):new(ip_address,"/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/public/data/location_ip_db.dat")
if not ipdetail then
    ngx.log(ngx.ERR, err)
    ngx.say(failure(err))
    return
end

local ipLocation, err = ipdetail:location()
if not ipLocation then
    ngx.log(ngx.ERR, err)
    ngx.say(failure(err))
    return
end

ngx.say(success(ipLocation))
