--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/5/19
-- Time: 22:31
-- To change this template use File | Settings | File Templates.
--

local template = require "resty.template"
local mysql = require 'vendor.mysql_fun'
local helper = require "vendor.helper"
local cjson = require 'cjson'
local arg = helper.http_args()
local live_id = arg.live_id
local res = mysql.select(live_id)

if res.error_code ~= 200 then
    ngx.log(ERROR, 'server error')
    -- 跳到一个错误页面去
    ngx.exit(500)
end
--ngx.print(cjson.encode(res))
--ngx.print(res.error_code)
--ngx.print(res.result.name)
template.render("index.html", { hls_address = res.result.address })

