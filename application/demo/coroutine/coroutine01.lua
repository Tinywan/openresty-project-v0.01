--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/20
-- Time: 9:05
-- To change this template use File | Settings | File Templates.
--
function fun1()
    ngx.say("hello world")
end
-- 创建 coroutine
co = coroutine.create(fun1)
-- 输出 suspended
ngx.say(coroutine.status(co))

