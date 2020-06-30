#!/bin/bash

# Single Node ES 7.5.0 Deployment With Security Authentication

# 1. preparation before installation
# 1.1 check datadir of es
if [ ! -e /elk/data ];then
	mkdir -p /elk/data
fi
if [ ! -e /elk/logs ];then
	mkdir -p /elk/logs
fi
chmod -R 777 /elk/

# 1.2 check if firewalld is down
if [ $(systemctl is-active firewalld) -eq "active" ];then
	systemctl stop firewalld
fi

# 1.3 config system.conf
sed -i "s/$(sed -n '/DefaultLimitNOFILE/p' /etc/systemd/system.conf)/DefaultLimitNOFILE=65535/g" /etc/systemd/system.conf
sed -i "s/$(sed -n '/DefaultLimitMEMLOCK/p' /etc/systemd/system.conf)/DefaultLimitMEMLOCK=infinity/g" /etc/systemd/system.conf
sed -i "s/$(sed -n '/DefaultLimitNPROC/p' /etc/systemd/system.conf)/DefaultLimitNPROC=32000/g" /etc/systemd/system.conf
systemctl daemon-reexec

# 1.4 check if elasticsearch-7.5.0 and kibana-7.5.0 exists
if [ ! -e ~/elasticsearch-7.5.0-x86_64.rpm ];then
	echo -e "\033[31melasticsearch-7.5.0-x86_64.rpm doesn't exists. quit installation..........\033[0m"
	exit 0
fi
if [ ! -e ~/kibana-7.5.0-x86_64.rpm ];then
	echo -e "\033[31mkibana-7.5.0-x86_64.rpm doesn't exists. quit installation..........\033[0m"
	exit 0
fi

# 2. start installation of es and kibana
# 2.1 installation
rpm -i ~/elasticsearch-7.5.0-x86_64.rpm ~/kibana-7.5.0-x86_64.rpm

# 2.2 backup the config of es
cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak-$(date +%Y%m%d-%T)

# 2.3 reconfig and restart
NODE_NAME="node-1"
cat << EOF > /etc/elasticsearch/elasticsearch.yml
node.name: $NODE_NAME
path.data: /elk/data
path.logs: /elk/logs
bootstrap.memory_lock: true
network.host: 0.0.0.0
http.port: 9200
discovery.type: "single-node"
http.cors.enabled: true
http.cors.allow-origin: "*"
xpack.security.enabled: true
EOF
systemctl daemon-reload
systemctl start elasticsearch
sleep 5
echo -e "\033[32mES is $(systemctl is-active elasticsearch)\n\033[0m"

# 2.4 generate account for authentication
echo "y" | /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto > /usr/share/elasticsearch/elastic_pass.txt

# 2.5 test 
ELASTIC_PASS=$(sed -n "/PASSWORD elastic/p" /usr/share/elasticsearch/elastic_pass.txt | awk '{print $4}')
IPADDR=$(ifconfig eth0 |grep 'inet ' | awk '{print $2}')
curl --user elastic:$ELASTIC_PASS $IPADDR:9200/_cat/nodes?v