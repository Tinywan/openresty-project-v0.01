--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/5/25
-- Time: 23:13
-- To change this template use File | Settings | File Templates.
--
local helper = require 'vendor.helper'
--local args = ngx.req.get_uri_args()
local args = helper.http_args()
for key, val in pairs(args) do
    if type(val) == "table" then
        ngx.say(key, ": ", table.concat(val, ", "))
        args[key] = val
    else
        ngx.say(key, ": ", val)
        args[key] = val
    end
end
--local http_args = helper.http_args()
--ngx.say(http_args.id);

--ngx.print('var.request_method' .. ngx.var.request_method)

