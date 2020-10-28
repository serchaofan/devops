#!/bin/bash

# Single Node ES(7.x Latest Version) Deployment With Security Authentication

[ -f "/etc/rc.d/init.d/functions" ] && . /etc/rc.d/init.d/functions

check_dir_exist() {
	[ ! -e /elk/data -o ! -e /elk/logs ] && {
    	mkdir -p /elk/{data,logs}
    	chmod -R 777 /elk
	}
	action "-> Create ELK dir /elk" true
}

stop_firewalld() {
	systemctl stop firewalld
	systemctl disable firewalld
	action "-> Stop and Disable firewalld" true
}

setup_limit() {
	sed -i '/DefaultLimitNOFILE/c DefaultLimitNOFILE=65535' /etc/systemd/system.conf
	sed -i '/DefaultLimitMEMLOCK/c DefaultLimitMEMLOCK=infinity' /etc/systemd/system.conf
	sed -i '/DefaultLimitNPROC/c DefaultLimitNPROC=32000' /etc/systemd/system.conf
	systemctl daemon-reexec
	action "-> Set DefaultLimit" true
}

setup_elastic_repo() {
	cat < EOF > /etc/yum.repo.d/elastic.repo
	[elasticsearch]
	name=Elasticsearch repository for 7.x packages
	baseurl=https://mirrors.tuna.tsinghua.edu.cn/elasticstack/7.x/yum
	gpgcheck=1
	gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
	enabled=1
	autorefresh=1
	type=rpm-md
	EOF

	yum makecache &>/dev/null
	action "-> Setup Elasticstack Repo" true
}

install_elasticsearch() {
	yum install -y elasticsearch &>/dev/null
	action "-> Install Elasticsearch" true
}

install_kibana() {
	yum install -y kibana &>/dev/null
	action "-> Install Kibana" true
}

setup_jdk() {
	yum install java-1.8.0-openjdk-headless java-1.8.0-openjdk java-1.8.0-openjdk-devel -y &>/dev/null
	[[ -z $(echo $JAVA_HOME) ]] && {
		export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
		export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
		export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
		echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk' >> /etc/profile
		echo 'export CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib' >> /etc/profile
		echo 'export PATH=\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$PATH' >> /etc/profile
	}
	action "-> Setup JDK Env" true
}



check_dir_exist
stop_firewalld
setup_limit
setup_jdk
setup_elastic_repo
install_elasticsearch
install_kibana