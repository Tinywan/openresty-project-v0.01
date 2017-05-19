--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/5/19
-- Time: 22:34
-- To change this template use File | Settings | File Templates.
--

--加载Lua模块库
local template = require("resty.template")
--1、获取请求参数中的商品ID
local skuId = ngx.req.get_uri_args()["skuId"];
ngx.say(skuId)
----2、调用相应的服务获取数据
--local data = api.getData(skuId)
--
----3、渲染模板
local func = template.compile("product.html")
local world    = func{ message = "Hello, World!" }
local universe = func{ message = "Hello, Universe!" }
print(world, universe)


