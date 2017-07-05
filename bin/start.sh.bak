#!/bin/bash
#get nginx.conf path
#CONF_FILE_PATH=$(sudo find / -type f -name 'nginx.conf' | grep lua_project_v0.01 | xargs ls)
# get Nginx Pid
PID=$(ps -aef | grep nginx | grep -v grep | grep master |awk '{print $2}')
if [[ $? == 0 && -n $PID ]]
then
    echo -e "\033[35m [ Nginx running ] \033[0m"
    #确认nginx配置文件的语法是否正确，否则nginx将不会加载新的配置文件
    sudo /opt/openresty/nginx/sbin/nginx  -t -c /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/conf/nginx.conf
    #sudo /opt/openresty/nginx/sbin/nginx  -s reload
    sudo kill -HUP $PID
    echo -e "\033[33m [ Nginx has reload ] \033[0m"
else
    echo -e "\033[31m [ Stop OK ] \033[0m"
    sudo /opt/openresty/nginx/sbin/nginx  -t -c /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/conf/nginx.conf
    sudo /opt/openresty/nginx/sbin/nginx  -c /mnt/hgfs/Linux-Share/Lua/lua_project_v0.01/conf/nginx.conf
    echo -e "\033[32m [ Start OK ] \033[0m"
fi
exit 1
