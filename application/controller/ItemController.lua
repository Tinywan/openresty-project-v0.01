--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/5/19
-- Time: 22:31
-- To change this template use File | Settings | File Templates.
--
local common = require("item.common")
local helper = require 'vendor.helper'
local read_redis = common.read_redis
local read_http = common.read_http
local cjson = require("cjson")
local cjson_decode = cjson.decode
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_exit = ngx.exit
local ngx_print = ngx.print
local ngx_var = ngx.var

local skuId = ngx_var.skuId
--获取基本信息
local basicInfoKey = "ITEM:" .. skuId
local name = "name"
local basicInfoStr = read_redis("127.0.0.1", 63700,'tinywan123456', {basicInfoKey})
if not basicInfoStr then
    ngx_log(ngx_ERR, "redis not found basic info, back to http, skuId : ", skuId)
    basicInfoStr = read_http({type="basic", skuId = skuId})
end

if not basicInfoStr then
    ngx_log(ngx_ERR, "http not found basic info, skuId : ", skuId)
    return ngx_exit(ngx.HTTP_NOT_FOUND)    -- 404
end
--local obj_obj = helper.cjson_decode(basicInfoStr)
--if obj_obj == nil
--    then
--    ngx.say('cjson error')
--else
--    ngx.say(obj_obj.is_male, "<br/>")
--    ngx.say(obj_obj.hobby.name, "<br/>")
--    ngx.say(obj_obj.hobby.age, "<br/>")
--    ngx.say(obj_obj.hobby.reader, "<br/>")
--end
--ngx.exit(ngx.HTTP_OK)
basicInfo = cjson_decode(basicInfoStr)
--local ps3Id = basicInfo["is_male"]
--local brandId = basicInfo["hobby"]["name"]
--local age = basicInfo["hobby"]["age"]
--local reader = basicInfo["hobby"]["reader"]
----获取其他信息
--local breadcrumbKey = "s:" .. ps3Id .. ":"
--local brandKey = "b:" .. brandId ..":"
--local otherInfo = read_redis("127.0.0.1", 1116, {breadcrumbKey, brandKey}) or {}
--local breadcrumbStr = otherInfo[1]
--local brandStr = otherInfo[2]
--if breadcrumbStr then
--    basicInfo["breadcrumb"] = cjson_decode(breadcrumbStr)
--end
--if brandStr then
--    basicInfo["brand"] = cjson_decode(brandStr)
--end
--if not breadcrumbStr and not brandStr then
--    ngx_log(ngx_ERR, "redis not found other info, back to http, skuId : ", brandId)
--    local otherInfoStr = read_http({type="other", ps3Id = ps3Id, brandId = brandId})
--    if not otherInfoStr then
--        ngx_log(ngx_ERR, "http not found other info, skuId : ", skuId)
--    else
--        local otherInfo = cjson_decode(otherInfoStr)
--        basicInfo["breadcrumb"] = otherInfo["breadcrumb"]
--        basicInfo["brand"] = otherInfo["brand"]
--    end
-- end
local str2 = "{\"hobby\":{\"name\":\"tinywan0007\",\"age\":84,\"reader\":\"ALIBABA\"},\"is_male\":false}"
local template = require "resty.template"
--template.caching(true)
template.render("item.html", cjson_decode(str2))
