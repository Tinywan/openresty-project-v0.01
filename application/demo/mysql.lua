--[[-----------------------------------------------------------------------
* |  Copyright (C) Shaobo Wan (Tinywan)
* |  Github: https://github.com/Tinywan
* |  Author: Tinywan
* |  Date: 2017/5/8 16:25
* |  Mail: Overcome.wan@Gmail.com
* |------------------------------------------------------------------------
* |  version: 1.0
* |  description: m
* |------------------------------------------------------------------------
--]]
local args = ngx.req.get_uri_args()
local action = args['action']

local mysql = require 'resty.mysql'
local cjson = require 'cjson'
local db_config = {
    host = '192.168.137.200',
    port = 3306,
    database = 'test',
    user = 'root',
    password = '123456',
    table = 'tb_user'
}

local db, err = mysql:new()
if not db then
    ngx.say(cjson.encode({code=500, message='未安装mysql客户端'}))
    return
end
local ok, err, errno, sqlstate = db:connect({
    host = db_config.host,
    port = db_config.port,
    database = db_config.database,
    user = db_config.user,
    password = db_config.password})
if not ok then
    ngx.say(cjson.encode({code=500, message='mysql连接不上'..err}))
    return
end

-- 列表
function lists()
    local data = {}
    ngx.req.read_body()
    local posts = ngx.req.get_post_args()
    local page, pagesize, offset = 0, 15, 0
    if posts.page then
        page = posts.page
    end
    if posts.pagesize then
        pagesize = posts.pagesize
    end
    if page > 1 then
        offset = (page -1)*pagesize
    end

    local res, err, errno, sqlstate = db:query('SELECT * FROM `'..db_config.table..'` LIMIT '..offset..','..pagesize)
    if not res then
        ngx.say(cjson.encode({code=200, message=err, data=nil}))
    else
        ngx.say(cjson.encode({code=200, message="", data=res}))
    end

end

-- add
function add()
    ngx.req.read_body()
    local data = ngx.req.get_post_args()
    if  data.name ~= nil then
        local sql = 'INSERT INTO '..db_config.table..'(name) VALUES ("'..data.name..'")';
        local res, err, errno, sqlstate = db:query(sql)
        if not res then
            ngx.say(cjson.encode({code=501, message="添加失败"..err..';sql:'..sql, data=nil}))
        else
            ngx.say(cjson.encode({code=200, message="添加成功", data=res.insert_id}))
        end
    else
        ngx.say(cjson.encode({code=501, message="参数不对", data=nil}))
    end
end

-- detail
function detail()
    ngx.req.read_body()
    local post_args = ngx.req.get_post_args()
    if post_args.id ~= nil then
        local data, err, errno, sqlstate = db:query('SELECT * FROM '..db_config.table..' WHERE id='..post_args.id..' LIMIT 1', 1)
        local res = {}
        if data ~= nil then
            res.code = 200
            res.message = '请求成功'
            res.data = data[1]
        else
            res.code = 502
            res.message = '没有数据'
            res.data = data
        end
        ngx.say(cjson.encode(res))
    else
        ngx.say(cjson.encode({code = 501, message = '参数错误', data = nil}))
    end

end

-- delete
function delete()
    ngx.req.read_body()
    local data = ngx.req.get_post_args()
    if data.id ~= nil then
        local res, err, errno, sqlstate = db:query('DELETE FROM '..db_config.table..' WHERE id='..data.id)
        if not res or res.affected_rows < 1 then
            ngx.say(cjson.encode({code = 504, message = '删除失败', data = nil}))
        else
            ngx.say(cjson.encode({code = 200, message = '修改成功', data = nil}))
        end
    else
        ngx.say(cjson.encode({code = 501, message = '参数错误', data = nil}))
    end
end

-- update
function update()
    ngx.req.read_body()
    local post_args = ngx.req.get_post_args()
    if post_args.id ~= nil and post_args.name ~= nil then
        local res, err, errno, sqlstate = db:query('UPDATE '..db_config.table..' SET `name` = "'..post_args.name..'" WHERE id='..post_args.id)
        if  not res or res.affected_rows < 1 then
            ngx.say(cjson.encode({code = 504, message = '修改失败', data = nil}));
        else
            ngx.say(cjson.encode({code = 200, message = '修改成功', data = nil}))
        end
    else
        ngx.say(cjson.encode({code = 501, message = '参数错误', data = nil}));
    end
end

if action == 'lists' then
    lists()
elseif action == 'detail' then
    detail()
elseif action == 'add' then
    add()
elseif action == 'delete' then
    delete()
elseif action == 'update' then
    update()
end




