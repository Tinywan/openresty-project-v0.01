#!/bin/bash
#######################################################
# $Name:         start.sh
# $Version:      v1.0
# $Function:     Nginx start script
# $Author:       ShaoBo Wan (Tinywan)
# $organization: https://github.com/Tinywan
# $Create Date:  2017-07-05
# $Description:  Nginx start script
#######################################################
# update 1
NGINX_SBIN_PATH="/opt/openresty/nginx/sbin/nginx"
# update 1
NGINX_CONFIG_PATH="/home/www/lua_project_v0.01/conf/nginx.conf"
PID=$(ps -aef | grep nginx | grep -v grep | grep master |awk '{print $2}')
shell_usage(){
    echo $"Usage: $0 start|stop"
}

start_nginx(){
    if [[ $? == 0 && -n $PID ]]
    then
        echo -e "\033[35m [ Nginx running ] \033[0m"
        sudo $NGINX_SBIN_PATH  -t -c $NGINX_CONFIG_PATH
        sudo kill -HUP $PID
        echo -e "\033[33m [ Nginx has reload ] \033[0m"
    else
        echo -e "\033[31m [ Stop OK ] \033[0m"
        sudo $NGINX_SBIN_PATH  -t -c $NGINX_CONFIG_PATH
        sudo $NGINX_SBIN_PATH  -c $NGINX_CONFIG_PATH
        echo -e "\033[32m [ Start OK ] \033[0m"
    fi
}

stop_nginx(){
    sudo kill -QUIT ${PID}
    if [[ $? == 0 &&  -n $PID ]]
    then
        echo -e "\033[33m [ Stop Success ] \033[0m"
    else
        echo -e "\033[31m [ Stop Fail ] \033[0m"
    fi
    exit 1
}

# Main Function
main(){
    case $1 in
        start) start_nginx
        ;;
        stop) stop_nginx
        ;;
        *) shell_usage
        ;;
    esac
}

main $1
