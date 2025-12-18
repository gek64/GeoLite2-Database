#!/usr/bin/env sh

LIST='geolocation-!cn,category-games-!cn,category-pt,category-porn'
IP_ADDRESS="127.0.0.1"
PORT="9953"
OUTPUT_FILE="./dnsmasq.servers"

run() {
    # 创建工作目录
    mkdir -p geo2dnsmasq

    # 下载 geoview
    curl -Lo geo2dnsmasq/geoview https://github.com/snowie2000/geoview/releases/latest/download/geoview-linux-amd64
    chmod +x geo2dnsmasq/geoview

    # 下载 dat 文件
    curl -Lo geo2dnsmasq/geoip.dat https://fastly.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat
    curl -Lo geo2dnsmasq/geosite.dat https://fastly.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat

    # 提取域名
    geo2dnsmasq/geoview -type geosite -input geo2dnsmasq/geosite.dat -list "$LIST" -output geo2dnsmasq/geosite.txt

    # 逐行读取 sites.txt 文件
    while IFS= read -r line; do
        # 去除行首和行尾的空白字符
        trimmed_line=$(echo "$line" | xargs)

        # 格式化输出
        formatted_output="server=/$trimmed_line/$IP_ADDRESS#$PORT"

        # 将格式化输出追加到输出文件中
        echo "$formatted_output" >>"$OUTPUT_FILE"
    done <geo2dnsmasq/geosite.txt

    # 清理工作目录
    rm -rf geo2dnsmasq
}

# 脚本程序基础 ---------------------------------------------------------------------------------------------------------
## 显示帮助信息(heredoc)
Show_help() {
    cat <<-EOF
Version:
  1.00
Usage:
  $0 [Arguments]
Arguments:
  -l   : set geosite lists
  -a   : set dns ip address
  -p   : set dns port
  -o   : set output file
  -h   : show help
EOF
}

## 初始化配置
Init() {
    while [ $# -gt 0 ]; do
        case "$1" in
        "-l")
            LIST="$2"
            shift 2
            ;;
        "-a")
            IP_ADDRESS="$2"
            shift 2
            ;;
        "-p")
            PORT="$2"
            shift 2
            ;;
        "-o")
            OUTPUT_FILE="$2"
            shift 2
            ;;
        "-h")
            Show_help
            exit 0
            ;;
        *)
            echo "$0: unknown arguments"
            Show_help
            exit 1
            ;;
        esac
    done

    run
}

Init "$@"
