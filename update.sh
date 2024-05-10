#!/bin/bash

set -e

M_PATH="/root/se/mosdns"
C_PATH="/etc/mosdns"
PM2_CONFIG="$C_PATH/pm2.json"

# 检查并安装 npm 和 pm2
install_dependencies() {
    if ! command -v pm2 &>/dev/null; then
        echo "pm2 is not installed. Installing npm and pm2..."
        apt-get update
        apt-get install -y npm
        npm install -g pm2
    fi
}

# 检查是否安装 pm2
check_pm2() {
    if ! command -v pm2 &>/dev/null; then
        echo "Error: pm2 is not installed and installation failed. Please install pm2 manually before running this script."
        exit 1
    fi
}

# 函数：下载并解压 mosdns
download_and_extract() {
    local latest_version=$(curl --silent -qI https://github.com/IrineSistiana/mosdns/releases/latest | awk -F '/' '/^location/ {print substr($NF, 1, length($NF)-1)}')
    mkdir -p "$M_PATH"
    cd "$M_PATH"
    wget -q --show-progress "https://github.com/IrineSistiana/mosdns/releases/download/$latest_version/mosdns-linux-amd64.zip"
    unzip -o "mosdns-linux-amd64.zip"
    rm -f "mosdns-linux-amd64.zip"
}

# 函数：更新配置
update_config() {
    if [ -d "$C_PATH" ]; then
        cd "$C_PATH"
        git pull
    fi
}

# 函数：重启 mosdns
restart_mosdns() {
    local pid=$(pm2 pid mosdns 2>/dev/null || true)
    if [ -z "$pid" ] || [ "$pid" = "0" ]; then
        echo "mosdns is not running. Starting..."
        pm2 start "$PM2_CONFIG"
    else
        echo "Restarting mosdns..."
        pm2 delete mosdns
        pm2 start "$PM2_CONFIG"
    fi
}

# 主程序

# 检查并安装 npm 和 pm2
install_dependencies

# 检查是否安装 pm2
check_pm2

# 下载并解压 mosdns
download_and_extract

# 更新配置
update_config

# 重启 mosdns
restart_mosdns

