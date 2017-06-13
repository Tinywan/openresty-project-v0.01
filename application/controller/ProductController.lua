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
local var = ngx.var
ngx.say(var.skuId .. '==URI == '.. ngx.time())
ngx.say(location.)
t = {name = "tinywan"}
mt = function ( str )
    return str + 10
end
setmetatable(t, mt)
print(t.name)

