# 一个简单的Lua 项目
使用Lua编写一个完整的项目

##  项目结构
```javascript
└── ProjectName
    ├── conf                    -- 配置文件
    │   └── nginx.conf          
    ├── logs                    -- 日志文件
    │   └── error.log           
    ├── lua                     -- lua脚本文件
    │   ├── functions.lua
    │   └── test.lua
    ├── lualib                  -- lua库文件
    │   ├── cjson.so
    │   ├── ngx
    │   │   └── ssl.lua
    │   ├── rds
    │   │   └── parser.so
    │   ├── redis
    │   │   └── parser.so
    │   ├── resty
    │   │   ├── redis.lua
    │   │   ├── upstream
    │   │   └── websocket
    │   └── vendor              -- 第三方、自定义库/lua文件
    │       └── ip_location.lua
    └── public                  -- 静态资源文件
        └── data
            └── 17monipdb.dat
```
## nginx.conf, the Nginx web server configuration

```lua
user  www www;
worker_processes  8;

error_log  logs/error.log;
pid        logs/nginx.pid;

events {
    use epoll;
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  text/html;
    lua_package_path app;  #lua 模块  
    lua_package_cpath "/home/tinywan/Openresty_Protect/ProjectName/lualib/?.so;;";  #c模块  
    include /home/tinywan/Openresty_Protect/ProjectName/conf/nginx.conf;
}

```