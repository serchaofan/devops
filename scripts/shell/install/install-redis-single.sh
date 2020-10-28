#!/bin/bash

yum install -y wget && rm -f /etc/yum.repos.d/*
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum makecache fast
yum groups mark install "Development Tools"
yum groups mark convert "Development Tools"
yum groups install -y "Development Tools"

yum install -y gcc tcl jemalloc
wget -O /tmp/redis-5.0.9.tar.gz https://download.redis.io/releases/redis-5.0.9.tar.gz
tar -xzf /tmp/redis-5.0.9.tar.gz -C /usr/local
mv /usr/local/redis-5.0.9 /usr/local/redis
cd /usr/local/redis
make && make install
