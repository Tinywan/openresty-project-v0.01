--
-- Created by IntelliJ IDEA.
-- User: tinywan
-- Date: 2017/5/23
-- Time: 21:26
-- To change this template use File | Settings | File Templates.
--
local var = ngx.var
local method = var.request_method
local get_args = ngx.req.get_uri_args()
ngx.req.read_body()
local post_args, err = ngx.req.get_post_args()
if not post_args then
    ngx.say("failed to get post args: ", err)
    return
end

--ngx.say('uri' .. var.uri)
--ngx.say('request_method ' .. var.request_method)
--ngx.say('content_type ' .. var.content_type)
--ngx.say('users info ' .. ngx.HTTP_GET)

-- 新增
function add()
    local name = post_args.name
    local age = post_args.age
    ngx.say('新增 name = ' .. name .. ' age = ' .. age)
end

-- 查询
function read()
    local id = get_args.id
    ngx.say('查询 id = ' .. id .. '用户信息')
end

-- 修改
function update()
    local name = post_args.name
    local age = post_args.age
    ngx.say('更新数据为 name = ' .. name .. ' age = ' .. age)
end

-- 删除
function delete()
    local id = get_args.id
    ngx.say('删除用户为 id = ' .. id .. '的信息')
end

--未知
function defautl()
    ngx.say('error')
end

if(method == "GET")
then
    --[ 在布尔表达式 1 为 true 时执行该语句块 --]
    read()
elseif(method == "POST")
then
    --[ 在布尔表达式 2 为 true 时执行该语句块 --]
    add()
elseif(method == "PUT")
then
    --[ 在布尔表达式 2 为 true 时执行该语句块 --]
    update()
elseif(method == "DELETE")
then
    --[ 在布尔表达式 2 为 true 时执行该语句块 --]
    delete()
else
    --[ 如果以上布尔表达式都不为 true 则执行该语句块 --]
    default()
end

