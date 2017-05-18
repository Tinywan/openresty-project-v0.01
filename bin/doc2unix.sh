#!/usr/bin/env bash
# test
PID=$(ps -aef | grep nginx | grep -v grep | grep master |awk '{print $2}')
echo $PID