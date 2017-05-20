--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/5/19 23:25
* |  Function: To change this template use File | Settings | File Templates.
* |------------------------------------------------------------------------
--]]

--加载Lua模块库
local template = require("resty.template")
--获取请求参数
local name = ngx.req.get_uri_args()["name"];
--渲染模板
template.render("index.html", {
    title = "Testing lua-resty-template",
    message = "Hello, World!",
    names = { "James", "Tinywan", "Anne" },
    jquery = '<script src="js/jquery.min.js"></script>'
})


