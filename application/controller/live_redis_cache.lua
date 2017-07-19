--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/5/19 23:25
* |  Function: local_live_test.
* |  TestInfo: port = 63700 auth = tinywan123456
* |  log [n] 这样子的log日志是可以删除的（）
* |------------------------------------------------------------------------
--]]
local template = require "resty.template"
local helper = require "vendor.helper"
local live_common = require "live.common"
local read_content = live_common.read_content
local test = live_common.test
local exit = ngx.exit
local ngx_var = ngx.var
local print = ngx.print

-- get var id
local id = ngx_var.id
local content = read_content(id)
-- 在控制条件中除了false和nil 为假，其他值都为真，所以lua认为0和空字符串也是真
if not content or content == nil then
    -- backup data
    template.render("404.html", {
        title = "404 界面",
    })
    exit(200)
end

-- backup data
members = { Tom = 10, Jake = 11, Dodo = 12, Jhon = 16 }
template.caching(true)
template.render("index.html", {
    live_id = id,
    title = "Openresty 渲染 html 界面",
    ws_title = "Openresty 渲染 websocket",
    content = helper.cjson_decode(content),
    members = members
})

