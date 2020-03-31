echo "Getting K8s..."
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum makecache fast
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
echo "是否安装etcd? (y/n)"
read choose
if [ $choose="y" -o $choose="yes" -o $choose="Y" ];then
	  yum install -y etcd
fi

echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(kubeadm completion bash)" >> ~/.bashrc
source ~/.bashrc

# initialize k8s
echo "输入k8s服务子网"
read subnet
cat << EOF > init-default.yml
imageRepository: registry.aliyuncs.com/google_containers
networking:
dnsDomain: cluster.local
serviceSubnet: "$subnet"
EOF

kubeadm config images list --config init-default.yml
kubeadm config images pull --config init-default.yml
