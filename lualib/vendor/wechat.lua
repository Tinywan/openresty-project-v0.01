-- Copyright (C) Shaobo Wan (Tinywan)

local cjson = require("cjson")
local http = require "resty.http"
local log = ngx.log
local err = ngx.ERR
local exit = ngx.exit
local ngx_var = ngx.var
local print = ngx.print
local redirect = ngx.redirect

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function(narr, nrec) return {} end
end


local _M = new_tab(0, 54)

_M._VERSION = '0.26'

local scope = "snsapi_userinfo"
local appid = 'wx94c43716d8a91f3f'

local function urlEncode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

local function urlDecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

-- 获取access_token
function _M.get_access_token()
end

-- 拉取用户信息
function _M.get_user_info()
    return print("拉去用户信息")
end

-- 入口文件
function _M.index()
    local redirect_uri = urlEncode('http://wanwecaht.amai8.com/wechat/Index/getUserInfo');
    local url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" ..appid .."&redirect_uri="..redirect_uri .."&response_type=code&scope="..scope.."&state=1234#wechat_redirect";
    return redirect('/getUserInfo')
end

return _M