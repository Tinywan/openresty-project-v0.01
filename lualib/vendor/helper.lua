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

--[[
-- 字符串分割
-- #demo
    local array = helper.split('a,b,v,b',',')
    for key,value in ipairs(array)
    do
      ngx.say(key, value) -- 1a,2b,3v,4b
    end
    -- array[1] = a
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

