#!/bin/bash

set -e
M_PATH=/root/se/mosdns
C_PATH=/etc/mosdns
VER=$(curl --silent -qI https://github.com/IrineSistiana/mosdns/releases/latest | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}')

if [ -d $M_PATH ]; then
    cd $M_PATH
    wget https://github.com/IrineSistiana/mosdns/releases/download/$VER/mosdns-linux-amd64.zip
    unzip -o mosdns-linux-amd64.zip
    rm mosdns-linux-amd64.zip
fi

if [ -d $C_PATH ]; then
    cd $C_PATH
    git pull
fi

pid=$(pm2 pid mosdns)
if [[ $pid = "" || $pid = "0" ]]; then
    echo "mosdns start waiting"
    pm2 start $C_PATH/pmm2.json
else
    echo "mosdns restart"
    pm2 restart mosdns
fi

