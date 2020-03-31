# get k8s
echo -e "\033[31mGetting K8s...\033[0m"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum makecache fast -y
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
echo -e "\033[31m是否安装etcd? (y/n)\033[0m"
read choose
if [ $choose="y" -o $choose="yes" -o $choose="Y" ];then
  yum install -y etcd
fi

echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(kubeadm completion bash)" >> ~/.bashrc
source ~/.bashrc

# initialize k8s
echo -e "\033[31m输入k8s服务子网\033[0m"
read subnet
cat << EOF > init-default.yml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
imageRepository: registry.aliyuncs.com/google_containers
kubernetesVersion: v$(rpm -qa | grep kubectl | awk -F'-' '{print $2}')
networking:
  serviceSubnet: "$subnet"
EOF

echo -e "\033[31m开始拉取镜像...\033[0m"
# kubeadm config images list --config init-default.yml
kubeadm config images pull --config init-default.yml

echo -e "\033[33m---------------K8s Installation Completed-------------
K8s version: v$(rpm -qa | grep kubectl | awk -F'-' '{print $2}') \033[0m"