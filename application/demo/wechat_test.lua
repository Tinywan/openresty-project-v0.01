--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/11
-- Time: 17:03
-- To change this template use File | Settings | File Templates.
--
local wechat = require "vendor.wechat"
ngx.say("_VERSION == "..wechat._VERSION)
ngx.say("_VERSION == "..wechat.index())

