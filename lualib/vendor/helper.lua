--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Blog: http://www.cnblogs.com/Tinywan
* |------------------------------------------------------------------------
* |  Date: 2017/5/20 9:29
* |  Function: helper function lib
* |------------------------------------------------------------------------
--]]
local find = string.find
local len = string.len
local sub = string.sub
local byte = string.byte
local tcp = ngx.socket.tcp
local null = ngx.null
local type = type
local pairs = pairs
local unpack = unpack
local setmetatable = setmetatable
local tonumber = tonumber
local tostring = tostring
local rawget = rawget
local request_method = ngx.var.request_method
local method = ngx.var.request_method
local cjson = require("cjson")

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 54)

_M._VERSION = '0.01'

-- add
function _M.add(a,b)
    return a + b
end

--[[    获取http get/post 请求参数
eg:
    local str1  = '{"hobby":{"name":"tinywan","age":24,"reader":"AMAI"},"is_male":false}'
    local obj_obj = cjson_decode(str1)
    if obj_obj == nil
    then
        ngx.say('cjson error')
    else
        ngx.say(obj_obj.is_male, "<br/>")
        ngx.say(obj_obj.hobby.name, "<br/>")
        ngx.say(obj_obj.hobby.age, "<br/>")
        ngx.say(obj_obj.hobby.reader, "<br/>")
    end
--]]
local function _json_encode(str)
    return cjson.encode(str)
end

local function _json_decode(str)
    return cjson.decode(str)
end

function _M.cjson_encode( str )
    local ok, t = pcall(_json_encode, str)
    if not ok then
        return nil
    end
    return t
end

function _M.cjson_decode( str )
    local ok, t = pcall(_json_decode, str)
    if not ok then
        return nil
    end
    return t
end

--[[    获取http get/post 请求参数
eg:
    post: curl -d "name=tinywan&age=24" http://127.0.0.1:8686/0.1/live/http_args
    get: curl -G -d "name=tinywan&age=24" http://127.0.0.1:8686/0.1/live/http_args
-- --]]

function _M.http_args()
    local request_method = ngx.var.request_method
    local args = ngx.req.get_uri_args()
    -- 参数获取
    if "POST" == request_method then
        ngx.req.read_body()
        local post_args = ngx.req.get_post_args()
        if post_args then
            for k, v in pairs(post_args) do
                args[k] = v
            end
        end
    end
    return args
end

--[[    字符串分割
eg:
    local array = helper.split('a,b,v,b',',')
    for key,value in ipairs(array)
    do
      ngx.say(key, value) -- 1a,2b,3v,4b
    end
-- --]]

function _M.split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = sub(szFullString, nFindStartIndex, len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

-- 删除空格 Delete the space
function _M.ltrim(s)
    if not s then
        return s
    end
    local res = s
    local tmp = string_find(res, '%S')
    if not tmp then
        res = ''
    elseif tmp ~= 1 then
        res = string_sub(res, tmp)
    end
    return res
end

function _M.rtrim(s)
    if not s then
        return s
    end
    local res = s
    local tmp = string_find(res, '%S%s*$')
    if not tmp then
        res = ''
    elseif tmp ~= #res then
        res = string_sub(res, 1, tmp)
    end

    return res
end

function _M.trim(s)
    if not s then
        return s
    end
    local res1 = ltrim(s)
    local res2 = rtrim(res1)
    return res2
end


return _M

