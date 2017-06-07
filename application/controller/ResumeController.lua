--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/5/19
-- Time: 22:31
-- To change this template use File | Settings | File Templates.
--
local template = require "resty.template"
local helper = require "vendor.helper"
local redis = require("resty.redis")
local cjson = require "cjson"
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local cjson_decode = cjson.decode

-- data

--local contact_tb = {} -- 联系方式
--contact_tb["email"] = "overcome.wan@Gmail.com"
--contact_tb["wechat"] = "wanwan756684177"
--contact_tb["qq"] = "756684177"
--
--local application_tb = {} -- 应聘岗位
--application_tb[1] = "application0001"
--application_tb[2] = "application0002"
--
--local technology_tb = {} -- 技能点
--technology_tb[1] = "JavaScript"
--technology_tb[2] = "HTML"
--technology_tb[3] = "Css"
--technology_tb[4] = "PHP"
--technology_tb[5] = "Lua"
--
----Basic info. 基本信息
--local basic_info_tb = {person_info="万少波/男/26岁",english="CET-4",GitHub="https://github.com/Tinywan",blog="http://www.cnblogs.com/Tinywan"}
--local all_info = {
--    contact = contact_tb,
--    application = application_tb,
--    technology = technology_tb,
--    basic_info = basic_info_tb
--}
--
---- 获取后端Mysql数据存储到Redis中去
-- close redis
local function close_redis(red)
    if not red then
        return
    end
    --释放连接(连接池实现)
    local pool_max_idle_time = 10000 --毫秒
    local pool_size = 100 --连接池大小
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)

    if not ok then
        ngx_log(ngx_ERR, "set redis keepalive error : ", err)
    end
end

--local red = redis:new()
--red:set_timeout(1000)
--local ip = "127.0.0.1"
--local port = 63700
--local auth = "tinywan123456"
--local ok, err = red:connect(ip, port)
--if not ok then
--    ngx_log(ngx_ERR, "connect to redis error : ", err)
--    return close_redis(red)
--end
--
--local res, err = red:auth(auth)
--if not res then
--    ngx.say("failed to authenticate: ", err)
--    return
--end
--local ok, err = red:set("all_info", cjson.encode(all_info))
--if not ok then
--    ngx_log(ngx_ERR, "failed to set : " .. id, err)
-- end

local red = redis:new()
red:set_timeout(1000)
local ip = "127.0.0.1"
local port = 63700
local auth = "tinywan123456"
local ok, err = red:connect(ip, port)
if not ok then
    ngx_log(ngx_ERR, "connect to redis error : ", err)
    return close_redis(red)
end

local res, err = red:auth(auth)
if not res then
    ngx.say("failed to authenticate: ", err)
    return
end

local resp, err = red:get("all_info")
if not resp then
    ngx_log(ngx_ERR, "get redis content error : ", err)
    return close_redis(red)
end
--得到的数据为空处理
if resp == ngx.null then
    resp = nil
end

local res = cjson.decode(resp)
--local tt = res["technology"]
--ngx.print(tt[1])
--ngx.print(res["application"][1])
ngx.say(#res["technology"])
--template.caching(true)
--template.render("resume/index2.html", {
--    message = "Hello, World!",
--    technology = res["technology"],
--    application = res["application"],
--    contact = res["contact"],
--})


