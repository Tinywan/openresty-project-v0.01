--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/6/6
-- Time: 22:21
-- To change this template use File | Settings | File Templates.
--
local bit = require("bit")
local utf8 = require("utf8")
local cjson = require("cjson")
local cjson_encode = cjson.encode
local bit_band = bit.band
local bit_bor = bit.bor
local bit_lshift = bit.lshift
local string_format = string.format
local string_byte = string.byte
local table_concat = table.concat

--utf8转为unicode
local function utf8_to_unicode(str)
    if not str or str == "" or str == ngx.null then
        return nil
    end
    local res, seq, val = {}, 0, nil
    for i = 1, #str do
        local c = string_byte(str, i)
        if seq == 0 then
            if val then
                res[#res + 1] = string_format("%04x", val)
            end

            seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                    c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
                    0
            if seq == 0 then
                ngx.log(ngx.ERR, 'invalid UTF-8 character sequence' .. ",,," .. tostring(str))
                return str
            end

            val = bit_band(c, 2 ^ (8 - seq) - 1)
        else
            val = bit_bor(bit_lshift(val, 6), bit_band(c, 0x3F))
        end
        seq = seq - 1
    end
    if val then
        res[#res + 1] = string_format("%04x", val)
    end
    if #res == 0 then
        return str
    end
    return "\\u" .. table_concat(res, "\\u")
end

--utf8字符串截取
local function trunc(str, len)
    if not str then
        return nil
    end

    if utf8.len(str) > len then
        return utf8.sub(str, 1, len) .. "..."
    end
    return str
end

--初始化面包屑
local function init_breadcrumb(info)
    local breadcrumb = info["breadcrumb"]
    if not breadcrumb then
        return
    end

    local ps1Id = breadcrumb[1][1]
    local ps2Id = breadcrumb[2][1]
    local ps3Id = breadcrumb[3][1]

    --此处应该根据一级分类查找url
    local ps1Url = "http://shouji.jd.com/"
    local ps2Url = "http://channel.jd.com/shouji.html"
    local ps3Url = "http://list.jd.com/list.html?cat=" .. ps1Id .. "," .. ps2Id .. "," .. ps3Id

    breadcrumb[1][3] = ps1Url
    breadcrumb[2][3] = ps2Url
    breadcrumb[3][3] = ps3Url
end

--初始化扩展属性
local function init_expand(info)
    local expands = info["expands"]
    if not expands then
        return
    end
    for _, e in ipairs(expands) do
        if type(e[2]) == "table" then
            e[2] = table_concat(e[2], "，")
        end
    end
end

--初始化颜色尺码
local function init_color_size(info)
    local colorSize = info["colorSize"]

    --颜色尺码JSON串
    local colorSizeJson = cjson_encode(colorSize)
    --颜色列表（不重复）
    local colorList = {}
    --尺码列表（不重复）
    local sizeList = {}
    info["colorSizeJson"] = colorSizeJson
    info["colorList"] = colorList
    info["sizeList"] = sizeList

    local colorSet = {}
    local sizeSet = {}
    for _, cz in ipairs(colorSize) do
        local color = cz["Color"]
        local size = cz["Size"]
        if color and color ~= "" and not colorSet[color] then
            colorList[#colorList + 1] = {color = color, url = "http://item.jd.com/" ..cz["SkuId"] .. ".html"}
            colorSet[color] = true
        end
        if size and size ~= "" and not sizeSet[size] then
            sizeList[#sizeList + 1] = {size = size, url = "http://item.jd.com/" ..cz["SkuId"] .. ".html"}
            sizeSet[size] = ""
        end
    end
end

local _M = {
    utf8_to_unicode = utf8_to_unicode,
    trunc = trunc,
    init_breadcrumb = init_breadcrumb,
    init_expand = init_expand,
    init_color_size = init_color_size
}

return _M


