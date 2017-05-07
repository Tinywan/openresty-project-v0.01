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
    
## 功能目录
####    简单的Redis数据库操作  
+   通过引入已经封装好的Redis类操作Redis数据
+   直接运行curl:`curl http://127.0.0.1/get_redis_iresty`
####    根据IP地址获取具体城市信息
+   根据IP地址，获取具体IP地址的城市详细信息
+   直接运行curl:`curl http://127.0.0.1/test_ip_location?ip='122.228.95.112'`
####    lua-resty-shell 库
+   执行shell命令
+   获取Linux的CPU信息：`curl http://127.0.0.1/shell_test`     
