# 一个简单的Lua 项目
使用Lua编写一个完整的项目

##  Project structure
```javascript
.
├── application
│   ├── get_redis_iresty.lua
│   ├── ip_location.lua
│   └── test.lua
├── conf
│   └── nginx.conf
├── logs
│   └── error.log
├── lualib
│   ├── cjson.so
│   ├── ngx
│   │   ├── balancer.lua
│   │   ├── ocsp.lua
│   │   ├── semaphore.lua
│   │   ├── ssl
│   │   └── ssl.lua
│   ├── rds
│   │   └── parser.so
│   ├── redis
│   │   └── parser.so
│   ├── resty
│   │   ├── aes.lua
│   │   ├── core
│   │   ├── core.lua
│   │   ├── dns
│   │   ├── http_headers.lua
│   │   ├── http.lua
│   │   ├── lock.lua
│   │   ├── lrucache
│   │   ├── lrucache.lua
│   │   ├── md5.lua
│   │   ├── memcached.lua
│   │   ├── mysql.lua
│   │   ├── random.lua
│   │   ├── redis_iresty.lua
│   │   ├── redis.lua
│   │   ├── sha1.lua
│   │   ├── sha224.lua
│   │   ├── sha256.lua
│   │   ├── sha384.lua
│   │   ├── sha512.lua
│   │   ├── sha.lua
│   │   ├── shell.lua
│   │   ├── string.lua
│   │   ├── upload.lua
│   │   ├── upstream
│   │   └── websocket
│   └── vendor
│       ├── ip_check.lua
│       └── ip_location.lua
├── public
│   └── data
│       └── location_ip_db.dat
└── README.md
```
## nginx.conf, the Nginx web server configuration

```lua
user  www www;
worker_processes  8;

pid        logs/nginx.pid;

events {
    use epoll;
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  "text/html";
    lua_package_path "/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/lualib/?.lua;;";   
    lua_package_cpath "/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/lualib/?.so;;";  
    include "/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/conf/nginx.conf";
}
```
##  :date:
####    2017年05月07日 星期日 
+   创建项目、项目架构搭建、目录结构调整
+   添加新功能
    - [x] 简单的Redis数据库操作 
    - [x] 根据IP地址获取具体城市信息(@icowan)
    - [x] lua-resty-shell库的使用
+   创建项目

####    2017年05月08日 星期一
+   添加新功能：lua-resty-websocket 官方测试案例
+   添加新功能：WebSocket系统负载统计
+   Mysql 管理待做...
        
## 功能列表
####    简单的Redis数据库操作  
+   通过引入已经封装好的Redis类操作Redis数据
+   直接运行curl:`curl http://127.0.0.1/get_redis_iresty`
####    根据IP地址获取具体城市信息
+   根据IP地址，获取具体IP地址的城市详细信息
+   直接运行curl:`curl http://127.0.0.1/test_ip_location?ip='122.228.95.112'`
####    lua-resty-shell 库
+   执行shell命令
+   获取Linux的CPU信息：`curl http://127.0.0.1/shell_test`   
####    lua-resty-websocket 官方测试案例
+   服务端文件`lua_websocket_server.lua`,客户端接受文件`public/index_default.html`,JS代码`public/static/stats_default.js`
+   服务端配置location
    ```lua
       location /lua_websocket_server {
           default_type text/html;
           content_by_lua_file /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/application/lua_websocket_server.lua;
       }
    ```
+   客户端，通过js`console.log(e.data)` 打印接收到的数据，这类我们可以接受到服务端发送的消息
   ```lua
   -- 服务端发送文本
   bytes, err = wb:send_text("Hello world Tinywan")
   
   --客户端接受数据，通过浏览器Console 可以看到以下数据
   Hello world Tinywan
   stats_default.js:70 Blob {size: 17, type: ""}
   stats_default.js:65 disconnect
   stats_default.js:60 connect
   ```
####    websocket系统负载统计
+   基于lua-resty-websocket实现系统负载监控
+   使用第三方编写的websocket_shell.lua(原本叫shell.lua) 一个库文件
+   第三方库或者文件引入：`local shell = require 'vendor.websocket_shell'`
+   注意：在这里并没有用到`lua-resty-shell` 库，有时间整合到一起去 
+   效果预览图：
    ![websocket_shell](https://github.com/Tinywan/lua_project_v0.01/blob/master/public/images/github/WebSocket_shell.jpg)
