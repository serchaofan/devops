echo "Getting Docker..."
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum install -y docker-ce
systemctl start docker && systemctl enable docker
echo "{\"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]}" > /etc/docker/daemon.json
systemctl daemon-reload && systemctl restart docker
echo -e "\033[33m---------------Docker Installation Completed------------- \033[0m
\033[33mDocker version:  \033[0m
\033[33m$(docker version | head -n3 | egrep "Version|API version")\033[0m"
