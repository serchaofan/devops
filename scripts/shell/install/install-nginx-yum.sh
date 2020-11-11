#!/bin/bash

cat <<EOF > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

yum makecache fast
yum install -f nginx
sleep 1
echo -e "\033[32m=========Nginx安装完成=========\033[0m"
echo -e "$(nginx -v)"
