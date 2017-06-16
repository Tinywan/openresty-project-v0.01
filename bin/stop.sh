#!/bin/bash
PID=$(ps -aef | grep nginx | grep -v grep | grep master |awk '{print $2}')
sudo kill -QUIT ${PID}
if [[ $? == 0 &&  -n $PID ]]
then
    echo -e "\033[33m [ Stop Success ] \033[0m"
else
    echo -e "\033[31m [ Stop Fail ] \033[0m"
fi
exit 1
