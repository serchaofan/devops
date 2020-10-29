#!/bin/bash

# Single Node ES 7.5.0 Deployment With Security Authentication

# 1. preparation before installation
# 1.1 check datadir of es
[ ! -e /elk/data -o ! -e /elk/logs ] && {
    mkdir -p /elk/data /elk/logs
    chmod -R 777 /elk
}

# 1.2 shutdown firewalld
systemctl stop firewalld

# 1.3 config system.conf
sed -i '/DefaultLimitNOFILE/c DefaultLimitNOFILE=65535' /etc/systemd/system.conf
sed -i '/DefaultLimitMEMLOCK/c DefaultLimitMEMLOCK=infinity' /etc/systemd/system.conf
sed -i '/DefaultLimitNPROC/c DefaultLimitNPROC=32000' /etc/systemd/system.conf
systemctl daemon-reexec

# 1.4 check if elasticsearch-7.5.0 and kibana-7.5.0 exists
[ ! -e ~/elasticsearch-7.5.0-x86_64.rpm -o ! -e ~/kibana-7.5.0-x86_64.rpm ] && {
    echo -e "\033[31m缺失rpm包\033[0m"
    exit 0
}

# 2. start installation of es and kibana
# 2.1 installation
rpm -i ~/elasticsearch-7.5.0-x86_64.rpm ~/kibana-7.5.0-x86_64.rpm

# 2.2 backup the config of es
cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak-$(date +%Y%m%d-%T)

# 2.3 reconfig and restart
NODE_NAME="node-1"
cat << EOF > /etc/elasticsearch/elasticsearch.yml
node.name: ${NODE_NAME}
path.data: /elk/data
path.logs: /elk/logs
bootstrap.memory_lock: true
network.host: 0.0.0.0
http.port: 9200
discovery.type: "single-node"
http.cors.enabled: true
http.cors.allow-origin: "*"
# xpack.security.enabled: true
EOF
systemctl daemon-reload
systemctl start elasticsearch
sleep 5
echo -e "\033[32mES is $(systemctl is-active elasticsearch)\n\033[0m"

# 2.4 generate account for authentication
# `echo "y" | /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto` > /usr/share/elasticsearch/elastic_pass.txt

# 2.5 test
ELASTIC_PASS=$(sed -n "/PASSWORD elastic/p" /usr/share/elasticsearch/elastic_pass.txt | awk '{print $4}')
IPADDR=$(ifconfig eth0 |grep 'inet ' | awk '{print $2}')
# curl --user elastic:$ELASTIC_PASS $IPADDR:9200/_cat/nodes?v
curl $IPADDR:9200/_cat/nodes?v