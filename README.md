![Markdown](https://github.com/Tinywan/lua_project_v0.01/blob/master/public/images/tinywan_title.png)
------
##  Wiki manual (Version_0.01)
[https://github.com/Tinywan/lua_project_v0.01/wiki](https://github.com/Tinywan/lua_project_v0.01/wiki)
##  Project structure
```javascript
.
├── application                     -- 业务代码 
│   ├── api                         -- API接口
│   │   ├── classes.lua
│   │   └── users.lua
│   ├── controller                  -- 业务控制器
│   │   ├── IndexController.lua
│   │   └── RedisController.lua
│   ├── model
│   │   └── Products.lua
│   └── zabbix
│       └── install-record01.conf
├── bin                             -- 脚本文件
│   ├── doc2unix.sh
│   ├── start.sh
│   └── stop.sh
├── cache
│   └── proxy_cache
├── conf                            -- 配置文件
│   ├── domains
│   │   ├── api.conf
│   │   └── waf.conf
│   ├── fastcgi_params
│   ├── nginx.conf
│   └── nginx_lua_upstream.conf
├── logs                            -- 日志文件 
│   ├── api_access.log
│   ├── hack
│   │   └── 2017-05-17_sec.log
│   └── waf_error.log
├── lualib                          -- 公共Lua库
│   ├── cjson.so
│   ├── ngx
│   │   └── ssl.lua
│   ├── resty
│   │   ├── dns
│   │   ├── redis.lua
│   │   ├── upstream
│   │   └── websocket
│   └── vendor                      -- 第三方Lua库
│       ├── config.lua
│       ├── dkjson.lua
│       ├── helper.lua
│       └── ip_location.lua
├── public                          -- 公共静态文件
│   ├── data
│   │   └── location_ip_db.dat
│   ├── images
│   │   ├── github
│   │   └── yinzhang.png
│   ├── upstream
│   │   ├── html8082
│   │   └── html8083
│   └── websocket
│       └── public
├── README.md
└── template                         -- 模板
    ├── index
    │   └── index.html
    ├── info
    │   ├── src
    │   └── wanshaobopdf.pdf
    ├── product
    │   ├── footer.html
    │   ├── header.html
    │   ├── index2.html
    │   ├── index.html
    │   └── product_list.html
    ├── waf
    │   ├── index.html
    │   └── waf.php
    └── websocket
        ├── index.html
        └── js
```
## Openresty Installation
+   Prerequisites：  
    ```
    apt-get install libreadline-dev libncurses5-dev libpcre3-dev \
    libssl-dev perl make build-essential
    ```
+   Building：
    ```bash
    wget https://openresty.org/download/openresty-1.11.2.3.tar.gz
    tar xvf openresty-1.11.2.1.tar.gz
    cd openresty-1.11.2.1
    ./configure --prefix=/opt/openresty \
                --with-luajit \
                --without-http_redis2_module \
                --with-http_iconv_module \
                --with-http_postgres_module 
    make -j2
    sudo make install
    ```
+   error
    +   错误1：`you need to have ldconfig in your PATH env when enabling luajit.`
    +   解决办法：
        ```bash
        sudo apt-get install luajit
        whereis luajit
        luajit: /usr/bin/luajit /usr/share/man/man1/luajit.1.gz

        ./configure --prefix=/opt/openresty \
                    --with-luajit=/usr/bin/luajit \
                    --without-http_redis2_module \
                    --with-http_iconv_module \
                    --with-http_postgres_module 
        make -j2
        sudo make install
        ```
## nginx.conf, the Nginx web server configuration

```bash
user  www www;
worker_processes  8;

pid       $PATH/lua_project_v0.01/logs/nginx.pid;
error_log $PATH/lua_project_v0.01/logs/error.log error;
worker_rlimit_nofile 204800;

events {
    use epoll;
    worker_connections  204800;
}

http {
    include       /opt/openresty/nginx/conf/mime.types;
    default_type  text/html;
    charset  utf-8;
    lua_package_path "$PATH/lua_project_v0.01/lualib/?.lua;;";  #lua 模块
    lua_package_cpath "$PATH/lua_project_v0.01/lualib/?.so;;";  #c模块
    include "$PATH/lua_project_v0.01/conf/domains/*";
}
```
## How to use
+   新建文件夹同时下载项目：
    ```javascript
    # 切换到 该目录，如果没有请重新建立
    www@iZ238xopqw6Z:~$ pwd
    /home/www
    git clone -b v0.03 https://github.com/Tinywan/lua_project_v0.01.git
    ```
+   修改主配置文件：`lua_project_v0.01/conf/nginx.conf` 的路径,以下的`/home/`修改为项目所在路径
    ```bash
    lua_package_path "/home/lua_project_v0.01/lualib/?.lua;/home/lua_project_v0.01/application/controller/?.lua";#lua 模块
    lua_package_cpath "/home/lua_project_v0.01/lualib/?.so;;";          #  c模块
    include "/home/lua_project_v0.01/conf/domains/*";
    ```
+   测试配置文件：`test.conf`
+   修改项目路径变量：`set $project_path /home/;`
    +   日志文件路径不支持变量(暂时需要修改，以后直接做跨域保存就可以了)：`access_log  "/home/lua_project_v0.01/logs/demo_access.log";`
+   启动脚本
    +   赋予权限（655）：`chmod +x /start.sh `,
    +   配置成功运行结果如下：
        ```bash
        /home/lua_project_v0.01/conf# ../bin/start.sh start
         [ Stop OK ] 
        nginx: the configuration file /home/lua_project_v0.01/conf/nginx.conf syntax is ok
        nginx: configuration file /home/lua_project_v0.01/conf/nginx.conf test is successful
         [ Start OK ]
        ```
+   测试流程是否跑通：`curl http://127.0.0.1/`,输出：`Hello! lua_project_v0.01`，表示环境配置成功
## branch list
+   master分支已经很稳定了，将不再提交代码，以后将从以下分支提交
+   公司`company`分支
+   家里`home`分支       
## config list
+   API接口专用（8686）：`api.conf`
+   Demo测试专用（8080）：`nginx_demo.conf`
+   活动直播专用（8088）：`nginx_live.conf`
+   Waf防火墙专用（8082）：`waf.conf`
+   商品列表专用（8083）：`nginx_product.conf`
##  error infomation
+   [解决nginx: [emerg] bind() to [::]:80 failed (98: Address already in use)](http://www.sjsjw.com/kf_system/article/167_16951_30655.asp)
+   错误日志：`[crit] 3478#0: *5 connect() to unix:/var/run/php7.0.9-fpm.sock failed (13: Permission denied)`
    +   修改php-fpm.conf配置文件
    ```bash
    listen.owner = nginx
    listen.group = nginx
    listen.mode = 0660
    ```
    +   跑nginx的用户是nginx，而/var/run/php7.0.9-fpm.sock 这个文件。监听的nginx用户没有该权限，导致nginx无法访问/var/run/php5-fpm.sock这个文件，自然监听就失去了效果。
##  helper 助手
- [x] 获取http get/post 请求参数：`helper.http_args()`
- [x] 字符串分割：`helper.split()`
- [x] 删除空格：`helper.ltrim() / rtrim() / trim()`
- [x] json 解析的异常：`helper.cjson_decode(str2)`
    +   错误返回nil，成功返回解析后的json字符串
    +   如何调用
    ```lua 
        local helper = require 'vendor.helper'
        local str1  = '{"hobby":{"name":"tinywan","age":24},"is_male":false}'    -- 写法1
        local str2  = [[ {"hobby":{"name":"tinywan","age":24},"is_male:false} ]] -- 写法2   
        local obj_obj = helper.cjson_decode(str2)
        if not json_str then
            ngx.say('cjson_decode error')
        else
            ngx.say(helper.format_table(json_str))
        end
    ```
##  Mysql 数据库操作
+   :white_check_mark: 添加
    ```lua
    local mysql = require 'vendor.mysql_fun'
    local cjson = require 'cjson'
    data = { name = "TinyWAN", address = "HeilongJiang", age = "26" }
    local result = mysql.add(data.name,data.address,data.age)
    ngx.print(cjson.encode(result))
    ```     
+   :white_check_mark: 查询  
    ```lua
    local result = mysql.select(3)
    ngx.print(cjson.encode(result))
    ```
+   :white_check_mark: 修改
    ```lua
    local result = mysql.update(3,"TinTinAIAI")
    ngx.print(cjson.encode(result))
    ```
+   :white_check_mark: 删除
    ```lua
    local result = mysql.delete(3)
    ngx.print(cjson.encode(result))
    ```
+   :white_check_mark: 数据返回结果：
    +   :heavy_check_mark:  成功
        ```json
        {
            "error_code": 200,
            "message": "add successfully"
        }
        ```
    +   :heavy_multiplication_x:   失败
        ```json
        {
            "error_code": 504,
            "message": "failed to delete"
        }
        ```
+  [mysql_fun.lua](https://github.com/Tinywan/lua_project_v0.01/blob/master/application/mysql/mysql_fun.lua)  
+   封装遇到的问题：
    +   nginx 错误日志总是出现这个：`lua entry thread aborted: runtime error: attempt to yield across C-call boundary`
    +   解决办法：[ngx_lua 连接mysql](http://wxianfeng.com/)
    +   封装好的文件：`/vendor/mysql_fun.lua`
    +   封装好调用的时候一直出现这个：`curl: (52) Empty reply from server`
    +   解决办法,在每次增删改查的时候都要调用数据库连接的这个方法数据库连接`connect_db()`方法就可以了
        ```lua
        function _M.update(id, name)
            connect_db()
        end
        ```
##  :date:
####    2017年05月07日 星期日 
+   创建项目、项目架构搭建、目录结构调整
+   添加新功能
    - [x] 简单的Redis数据库操作 
    - [x] 根据IP地址获取具体城市信息(@icowan)
    - [x] lua-resty-shell库的使用
####    2017年05月08日 星期一
+   添加功能：lua-resty-websocket 官方测试案例
+   添加功能：WebSocket系统负载统计
####    2017年05月10日 星期三
+   [Redis授权登录使用短连接(5000)和长连接(500W) 使用连接池AB压力测试结果](http://www.cnblogs.com/tinywan/p/6838630.html)        
####    2017年05月11日 星期四
+   Mysql 数据库添加
    +   错误提示：`bad result: Data too long for column 'name' at row 1: 1406: 22001.`,插入字段超过表定义大小
####    2017年05月14日 星期日
+   Swoole WebSocket 测试
    +   开启服务：`php /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/application/swoole/websocket-server.php`
    +   客户端测试：`http://127.0.0.1/clinet.html`
####    2017年05月15日 星期一
+   添加Nginx 启动脚本：`start.sh`
    +   开启Nginx：`/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/bin/start.sh`
    +   如果已经开始Nginx，则执行`start.sh `可以重新加载配置文件
+   添加Nginx 停止脚本：`stop.sh`
    +   停止Nginx：`/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/bin/stop.sh`
+   脚本运行错误：
    +   提示错误：` /bin/bash^M: 解释器错误: 没有那个文件或目录`
    +   解决办法：`sed -i 's/\r$//' ../lua_project_v0.01/bin/start.sh`
    +   [解决 linux下编译make文件报错“/bin/bash^M: 坏的解释器：没有那个文件或目录” 问题](http://blog.csdn.net/liuqiyao_01/article/details/41542101#comments)
    
####    2017年05月17日 星期三
+   ngx_lua_waf 安装使用(ngx_lua_waf是一个基于lua-nginx-module(openresty)的web应用防火墙) 
    +   [ngx_lua_waf github 地址](https://github.com/loveshell/ngx_lua_waf)
    +   安装步骤
        1.  下载源码到某一目录：复制目录到`application`下面，同时重命名`waf`
        2.  命令：`cp -R ngx_lua_waf /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/application/waf`
        3.  移动源文件目录中的`config.lua`文件到`../lualib/vendor`下
        4.  修改waf 目录下的`init.lua`文件的第一行：`require 'config'`修改为`require 'vendor.config'`
        5.  在`domains`目录下,新建文件`waf.conf`,添加以下内容
            ```lua
                lua_shared_dict limit 10m;
                init_by_lua_file  "/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/application/waf/init.lua";
                access_by_lua_file "/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/application/waf/waf.lua";
                
                server {
                    listen       8082;
                    server_name  localhost;
                    index  index.php index.html index.htm;
                    access_log  /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/logs/waf_access.log;
                    error_log /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/logs/waf_error.log error;
                
                    set $web_root /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/template/waf;
                    root $web_root;
                
                    location / {
                        try_files $uri $uri/ /index.php?$args;
                    }
                
                    location ~ \.php$ {
                        fastcgi_pass   unix:/var/run/php7.0.9-fpm.sock;
                        fastcgi_index  index.php;
                        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
                        include        fastcgi_params;
                    }
                }
            ```
        6.  重启Nginx即可 
           ```bash
            tinywan@tinywan:~$ /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/bin/start.sh 
            [ Nginx running ] 
            nginx: the configuration file /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/conf/nginx.conf syntax is ok
            nginx: configuration file /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/conf/nginx.conf test is successful
            [ Nginx has reload ]
           ```
        7.  可能会遇到的错误
            -   [1]`nginx: [emerg] open() "/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/conf/fastcgi_params" failed`
                 >  解决：`cp fastcgi_params /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/conf/fastcgi_params`
            -   [2]`FastCGI sent in stderr: "Primary script unknown" while reading response header from upstream`
                 >  解决：查看`waf.conf`配置信息是否正确 

+   修改文件：`config.lua`
    ```lua
    black_fileExt={"php","jsp"}
    ipWhitelist={"127.0.0.1"}
    --ipBlocklist={"1.0.0.1"}
    ipBlocklist={"192.168.127.133"}
    ```  
+   测试一：`http://127.0.0.1:8082/waf.php?id=../etc/passwd&name=Tinywan`     
    -   ![waf_ip_blaklist3](https://github.com/Tinywan/lua_project_v0.01/blob/master/public/images/github/waf_ip_blaklist3.png)
+   测试二：`http://192.168.127.133:8082/waf.php?id=../etc/passwd&name=Tinywan`     
    -   ![waf_ip_blaklist2](https://github.com/Tinywan/lua_project_v0.01/blob/master/public/images/github/waf_ip_blaklist2.png)
+   :poop: 坑 :poop: 在提交代码的时候`waf`目录一直提交不了，提示:`modified: xxx(modified content, untracked content)`,
    原来在`waf`目录下有个.git 目录,删除.git目录,重新git add 就可以了   
####    2017年05月19日 星期五
*  第一版采用单模块设计
*  简单的MVC模式，目录、命名约定（Phalcon MVC）
    +   Model（模型）负责在数据库中存取数据 
    +   View（视图）是应用程序中处理数据显示的部分     
    +   Controller（控制器）通常控制器负责从视图读取数据，控制用户输入，并向模型发送数据   
* 第一个简单的 mvc 模式的文件路径访问
1. 配置文件：`nginx_product.conf`  

    ```bash
    #upstream
    upstream item_http_upstream {
        server 192.168.1.1 max_fails=2 fail_timeout=30s weight=5;
        server 192.168.1.2 max_fails=2 fail_timeout=30s weight=5;
    }
    
    #缓存 共享字典配置
    lua_shared_dict item_local_shop_cache 600m;
    
    # server product
    server {
        listen       8082;
        server_name  127.0.0.1;
        charset gbk;
        index  index.html index.htm;
        access_log  /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/logs/product_access.log;
        error_log /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/logs/product_error.log error;
    
        #加载模板文件
        set $template_root /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/template;
    
        #url映射
        location ~* "^/product/(\d+)\.html$" {
            rewrite /product/(.*)    http://127.0.0.1:8082/$1 permanent;
        }
    
        # chapter
        location ~* "^/(\d{6,12})\.html$" {
            default_type text/html;
            lua_code_cache on;
            content_by_lua_file "/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/application/controller/ProductController.lua";
        }
    }
    ```
2. 当我们访问页面：`http://127.0.0.1:8082/13669361192.html`  
   将交给`lua_project_v0.01/application/controller/ProductController.lua`处理  
    
    ```html
    curl -k http://127.0.0.1:8082/13669361192.html
    Hello ProductController.lua
    uri = /13669361192.html
    ```
3. 项目入口搞定 :hibiscus: :hibiscus: :hibiscus: :hibiscus:        
 
* :bouquet: lua-resty-template 的使用    

    ```lua
        #加载模板文件
        set $template_root "/mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/template/product";
      
        location /template_test {
           default_type 'text/html';
           content_by_lua '
                local template = require "resty.template"
                template.render(chatroom.html, { message = "Hello, World!" })
           ';
        }
    ```
* :blossom: `resty.template`渲染模板,通过`ngx API`输出内容到指定的`html`页面  
    -  ![Markdown](https://github.com/Tinywan/lua_project_v0.01/blob/master/public/images/github/lua-resty-template.png)    
####    2017年05月20日 星期六
+   :white_check_mark: helper类的封装
    + Example
      ```lua
      local helper = require 'vendor.helper'
      local array = helper.split('a,b,v,b',',')
      for key,value in ipairs(array)
      do
        ngx.say(key, value)
      end
      ```     
+   :white_check_mark: dkjson 库的加入 :clap: :clap: :clap:  
    +   [常用Lua开发库2-JSON库、编码转换、字符串处理](http://jinnianshilongnian.iteye.com/blog/2187643)
    +   Example 
        ```lua
        local dkjson = require 'vendor.dkjson'
        --lua对象到字符串
        local obj = {
            id = 110,
            name = "Tinywan",
            age = 24,
            is_male = false,
            hobby = {"film", "music", "read"}
        }
        local str = dkjson.encode(obj, {indent = true})
        ngx.say(str, "<br/>")
        ```
+   :white_check_mark: 获取Redis数据库数据渲染到html模板页面显示
    +   数据显示、文件加载都合适
    +   :x: 问题：JS、CSS样式文件路径不合适 
+   :white_check_mark: Nginx+Lua逻辑开发 Redis 做为页面缓存
    +   Nginx 配置文件：`nginx_live.conf`      
    +   Lua 文件：`LiveRedisCacheController.lua` 
    +   `http://127.0.0.1:8088/ad/133456` 有缓存返回：`{"content":"Redis Cache Data"}`
    +   `http://127.0.0.1:8088/ad/13345` 没有缓存返回：`{"content":"MYSQL DATA \n"}`
+   :heavy_check_mark: 发布一个V0.01 版本 :pencil2: :pencil2: :pencil2: :pencil2:
####    2017年05月21日 星期日
+   :white_check_mark: 历史遗留问题解决：模板页面的JS、CSS样式文件加载不合适，忘记了Nginx处理静态资源的配置，添加以下代码OK
    ```javascript
    #配置Nginx动静分离，定义的静态页面直接从Nginx发布目录读取。
    location ~ .*\.(html|htm|gif|jpg|jpeg|bmp|png|ico|txt|js|css)$
    {
        root /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/template/info;
        #expires定义用户浏览器缓存的时间为7天，如果静态页面不常更新，可以设置更长，这样可以节省带宽和缓解服务器的压力
        expires      7d;
    }
    ```     
+   访问页面：`http://192.168.127.133:8083/2017TinywanInfo`可以得到响应内容  
####    2017年05月22日 星期一
+   标准os库,待补充 :negative_squared_cross_mark: :negative_squared_cross_mark: :negative_squared_cross_mark:
    +   `os.rename(oldname, newname)`:文件重命名
    +   `os.remove(filename)`:删除一个文件
    +   `os.execute(cmd)`:os.execute可运行一条系统命令，类似于C语言的system函数，`os.execute("mkdir /tmp/cq")`
    +   `os.exit(code)`:中止当前程序的执行，code参数默认值为true。
    +   `os.getenv(variable)`:返回环境变量的值，如果不存在，返回nil,`print(os.getenv('HOME')) -- /root`
    +   `os.time(tb)`:返回一个指定时间点的UNIX时间戳，如不带参数调用的话，就返回当前时间点的UNIX时间戳
####    2017年05月23日 星期二
+   API 的设计
    +   版本：`0.1`
    +   专用端口：`8686`
    +   配置文件
        ```lua
        location ~ ^/app/([-_a-zA-Z0-9/]+)$ {
            set $id $1;
            content_by_lua_file /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/application/api/${id}.lua;
        }
        ```
    +   curl访问地址：`curl http://127.0.0.1:8686/0.1/app/web文件名`
    +   访问案例：`curl http://127.0.0.1:8686/0.1/app/web`,将会执行`web.lua`文件
+   如何使用API接口
    +   :white_check_mark: 创建对象：
        ```javascript
        curl -X POST \
          -H "X-LC-Id: 558e20cbe4b060308e3eb36c" \
          -H "X-LC-Key: cbe4b06030558e208e3eb36c20cbe4b060308e3eb36c" \
          -H "Content-Type: application/json" \
          -d '{"name": "Tinywan","age": "26","tel": 13669361192}' \ 
          http://127.0.0.1:8686/0.1/users
        ```
    +   :white_check_mark: 查询信息：
        ```javascript
        curl -X GET \
          -H "X-LC-Id: {{appid}}" \
          -H "X-LC-Key: {{appkey}}" \
          -G \
          --data-urlencode 'id=9090' 
          http://127.0.0.1:8686/0.1/users
        ```
    +   :white_check_mark: 更新对象：
        ```javascript
        curl -X PUT \
          -H "X-LC-Id: {{appid}}" \
          -H "X-LC-Key: {{appkey}}" \
          -H "Content-Type: application/json" \
          -d "name=tinywan&age=26" \	
          http://127.0.0.1:8686/0.1/users

        ```
    +   :white_check_mark: 删除对象：
        ```javascript
        curl -X DELETE \
           -H "X-LC-Id: {{appid}}" \
           -H "X-LC-Key: {{masterkey}},master" \
           -G \
           --data-urlencode 'id=10' \
           http://127.0.0.1:8686/0.1/users 
        ```
####    2017年05月25日 星期四
+   活动直播接口 API 数据访问Redis，如果没有则回源到后端Mysql数据库
+   nginx.conf配置
    ```lua
    # 直播接口数据
    location ~ ^/0.1/live/([-_a-zA-Z0-9/]+) {
        content_by_lua_file /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/application/api/$1.lua;
    }

    # Redis 没有缓存数据则后端Mysql查询数据
    location /sub {
        internal;
        proxy_pass http://127.0.0.1:8686/backend/mysql;
    }

    # Backend Mysql Data
    location /backend/mysql {
         content_by_lua_block {
             ngx.say("backend post: Mysql ")
         }
    }
    ```
+   请求Example：
    +   访问如：`http://127.0.0.1:8686/0.1/live/live_redis_mysql?id=1122334`即可得到结果。而且注意观察日志，第一次访问时不命中Redis，回源到Mysql;第二次请求时就会命中Redis了。   
    +   第一次访问时将看到../logs/api_error.log输出类似如下的内容，而第二次请求相同的url不再有如下内容 
        ```javascript
         live_redis_mysql.lua:122: redis not cache content, Content comes from mysql , id : 1122334, 
         live_redis_mysql.lua:125: Content comes from Redis, id = 1122334, 
        ```
    +  [live_redis_mysql.lua](https://github.com/Tinywan/lua_project_v0.01/blob/master/application/api/live/live_redis_mysql.lua)     
####    2017年05月26日 星期五
+   nginx+lua+redis实现反向代理
+   端口：`8687`
+   [UpstreamBackendController.lua](https://github.com/Tinywan/lua_project_v0.01/blob/master/application/controller/UpstreamBackendController.lua)
+   参考文档：[利用nginx+lua+redis实现反向代理方法教程](http://www.jb51.net/article/113224.htm)
####    2017年05月31日 星期三
+   虚拟主机的项目根目录自定义，方便灵活修改
+   配置案例：
    ```lua
    server {
        listen       8080;
        # 定义项目根目录，在此本项目目录为虚拟机目录，你可以自定义为 /home/www/
        set $project_path /mnt/hgfs/Linux-Share/Lua/;  
        location /cjson_decode_pcall {
            content_by_lua_file "${project_path}lua_project_v0.01/application/demo/cjson.lua";
        }
    ```
####    2017年06月2日 星期五
+   API接口先查询Redis缓存数据，如果没有则到Mysql数据库查询获取,同时缓存数据到Redis中
+   访问地址返回数据：
   ```lua
   tinywan@tinywan:~$ curl http://127.0.0.1:8686/0.1/live/live_redis_to_mysql?id=3
   {"1":{"age":"24","name":"tinywan","address":"China","id":"3"},"Data_Sources":"Redis Cache Content"}
   ```
+  [live_redis_to_mysql.lua](https://github.com/Tinywan/lua_project_v0.01/blob/master/application/api/live/live_redis_to_mysql.lua)   
####   2017年06月4日 星期日  
+   获取Get 参数查询Mysql数据同时把数据在模板页面显示出来
+   参考代码：
    ```lua
    local template = require "resty.template"
    local mysql = require 'vendor.mysql_fun'
    local helper = require "vendor.helper"
    local arg = helper.http_args()
    local live_id = arg.live_id
    local res = mysql.select(live_id)
    local address = ""
    if res.error_code == 200 then
        address = res.result.address
    end
    template.render(chatroom.html, { hls_address = address })
    ``` 
+   ![websocket_shell](https://github.com/Tinywan/lua_project_v0.01/blob/master/public/images/github/lua_mysql_hls_address.png) 
####    2017年06月07日 星期三
+   商品的详情页页面数据显示(数据存储(Redis)的时候使用json格式存储，键约定：`ITEM:${Product_Id}`)
+   配置文件：`nginx_product.conf`
+   控制器文件：`ItemController.lua`
+   访问路径：`http://127.0.0.1:8087/item/13669361192` 即可把Redis的缓存数据渲染到html页面
+   所有的静态文件罗列在一个地方：
    +   Nginx配置：`root /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/public;`
    +   Html页面加载：`<script src="/video-js/videojs-contrib-hls.min.js"></script>`
+   下来要做的就是动态加载模板和数据、缓存处理...
####    2017年06月08日 星期四
+   一个简单的http请求获取数据，先Redis，再后台数据API，然后缓存在Redis（待优化，现在只是跑通一个DEMO）
+   ![location_lua_redis_backend](https://github.com/Tinywan/lua_project_v0.01/blob/master/public/images/github/location_lua_redis_backend.png)   
+   访问地址：`curl http://127.0.0.1:8088/live/1108`,请注意查看Log日志文件的变化
+   主要代码
    ```bash
    # 入口Lua文件的调用
    location ~ ^/live/(\d+)$ {
        set $id $1;
        content_by_lua_file "lua_project_v0.01/application/controller/LiveRedisCacheController.lua";
    }

    # 请求后端服务器的API接口查询数据，接口返回数据格式为Json格式
    location ~ /openapi/(.*) {
        internal;
        proxy_pass http://www.baidu.com;
    }
    ``` 
+   做个压力测试(主要是Redis连接数，并发太多将会出现超时问题，`netstat` 查看Redis连接数，好多"TIME OUT")，测试很糟糕的，QPS好低哦!
+   :x: :x: :x: :x: :x: :x: :x: :x: :x: 这块一定要优化！80%就大工搞成了 :x: :x: :x: :x:
+   修改后端API请求方式，由`ngx.location.capture` 转换为：`resty.http` 
    +   可能出现的错误：`resty.http API request error :no resolver defined to resolve "sewise.baidu.com"`
    +   解决办法，nginx.conf server节增加dns解析`resolver 8.8.8.8 114.114.114.114 valid=3600s;`
+   别人的建议：
    +   ![lua_redis](https://github.com/Tinywan/lua_project_v0.01/blob/master/public/images/github/lua_redis.png)
+   添加二级缓存(ngx.cache)
    +   访问地址：`http://127.0.0.1:8088/live/1063`
    +   缓存记录表
        ```bash
        +-------------+    +-------------+    +-------------+    +-------------+
        |   第一次访问  |--->|  ngx_cache  |--->| redis_cache |--->| backend API |
        +-------------+    +-------------+    +-------------+    +-------------+
                                                                       |                                         
        +-------------+    +-------------+    +-------------+          |
        |   第二次访问  |--->|  ngx_cache  |--->| redis_cache |<---------+
        +-------------+    +-------------+    +-------------+    
                                                     |
        +-------------+    +-------------+           |
        |   第三次访问  |--->|  ngx_cache  |<----------+
        +-------------+    +-------------+ 
        ```
    +   第一次访问日志记录
        ```bash
         [lua] CacheController.lua:145: ngx_cache not found content, request redis  db , id : 1066,
         [lua] CacheController.lua:61: read_redis(): get redis content error : LIVE_TABLE : 1066
         [lua] CacheController.lua:151: redis not found content, back to backend API , id : 1066
         [lua] CacheController.lua:133: read_http(): content from backend API id : 1066
        ```
    +   第二次访问日志记录
        ```bash
        [lua] CacheController.lua:145: ngx_cache not found content, request redis  db , id : 1066
        [lua] CacheController.lua:70: read_redis(): content from redis LIVE_TABLE:1066
        ```  
    +   第三次到第N次访问日志记
        ```bash
        [lua] CacheController.lua:39: get_cache(): content from ngx.cache id : LIVE_TABLE:1066
        [lua] CacheController.lua:39: get_cache(): content from ngx.cache id : LIVE_TABLE:1066
        [lua] CacheController.lua:39: get_cache(): content from ngx.cache id : LIVE_TABLE:1066
        ```  
    +   解决缓存失效风暴 lua-resty-lock [二级缓存]          
    +   缓存时间问题：ngx.cache目前默认为1s        
+   redis使用连接池、锁机制、二级缓存，全部为官方代码，第三方封装好的`redis_iresty`没有使用     
####    2017年06月16日 星期五
+   `resty.websocket.server`和`resty.redis` 实现聊天室功能    
+   请求访问地址：`http://192.168.18.180:8088/live/1138`    
+   [WebSocketRedisController.lua 文件](https://github.com/Tinywan/lua_project_v0.01/blob/master/application/controller/WebSocketRedisController.lua)    
+   ![live_room.png](https://github.com/Tinywan/lua_project_v0.01/blob/master/public/images/github/live_room.png)   
+   :x::x::x::x::x::x:待解决` lua tcp socket read timed out` 问题, 
+   需要深入研究的API` ngx.thread.spawn` 轻线程知识的学习, 
    
##  openresty进行了简化成了7个阶段
+   `set_by_lua`: 流程分支判断，判断变量初始哈
+   `rewrite_by_lua`: 用lua脚本实现nginx rewrite
+   `access_by_lua`: ip准入，是否能合法性访问，防火墙
+   `content_by_lua`: 内存生成
+   `header_filter_by_lua`：过滤http头信息，增加头信息
+   `body_filter_by_lua`: 内容大小写，内容加密
+   `log_by_lua`: 本地/远程记录日志
+   其实可以只用 `content_by_lua`，所有功能都在该阶段完成，也是可以的
## 功能列表
####    简单的Redis数据库操作  
+   通过引入已经封装好的Redis类操作Redis数据
+   直接运行curl:`curl http://127.0.0.1/get_redis_iresty`
+   官方短连接和长连接测试已通过（本地环境）
+   官方短连接和长连接测试已通过（本地环境）
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
####    nginx proxy_cache 缓存配置
+   配置代理
    +   访问8082 服务器代理到8083 服务器代理缓存已经 :ok:
    +   测试访问：`http://192.168.127.133:8082/2017TinywanInfo` 
    +   :x: 清理缓存配置 ，由于清除模块没有安装,没有进行测试
+   参考文献      
    +   [nginx proxy_cache 缓存配置](http://blog.csdn.net/dengjiexian123/article/details/53386586)  
    +   [nginx: [emerg] unknown directive "proxy_cache_purge](http://www.linuxidc.com/Linux/2013-11/93021.htm)  
    +   [nginx proxy cache 为了防止恶意刷页面/热点页面访问频繁](http://jinnianshilongnian.iteye.com/blog/2188538?page=2#comments)  
+   画图
```bash
                   +-------------+
                   |    uplink   |
                   +-------------+
                          |
                          +
    MASTER            keep|alived         BACKUP
172.29.88.224      172.29.88.222      172.29.88.225
+-------------+    +-------------+    +-------------+
|   nginx01   |----|  virtualIP  |----|   nginx02   |
+-------------+    +-------------+    +-------------+
                          |
       +------------------+------------------+
       |                  |                  |
+-------------+    +-------------+    +-------------+
|    web01    |    |    web02    |    |    web03    |
+-------------+    +-------------+    +-------------+


+-------------+    +-------------+    +-------------+    +-------------+
|   第一次访问  |--->|  ngx_cache  |--->|   redis     |--->| backend API |
+-------------+    +-------------+    +-------------+    +-------------+

+-------------+    +-------------+    +-------------+ 
|   第二次访问  |--->|  ngx_cache  |--->|   redis     |
+-------------+    +-------------+    +-------------+    

+-------------+    +-------------+ 
|   第三次访问  |--->|  ngx_cache  |
+-------------+    +-------------+   
```   
    