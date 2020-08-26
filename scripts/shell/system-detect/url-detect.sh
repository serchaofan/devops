#!/bin/bash

[[ -z "$1" ]] && {
    echo "$0 <url>"
    exit 1
}

echo "访问$1的统计数据："
curl -L -w '
请求完整URL:\t%{url_effective}
跳转实际URL:\t%{redirect_url}
HTTP返回码:\t%{http_code}
URL协议:\t%{scheme}
远端IP:\t%{remote_ip}
远端端口:\t%{remote_port}

返回内容大小:\t%{size_download}
重定向次数:\t%{num_redirects}
域名解析时长:\t%{time_namelookup}
建立链接时长:\t%{time_connect}
开始传输时长:\t%{time_starttransfer}
总时长:\t\t%{time_total}
' -o /dev/null -s "$1"
