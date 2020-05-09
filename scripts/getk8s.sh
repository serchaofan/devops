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

cat << EOF > /etc/sysctl.d/k8s.conf
et.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF

swapoff -a
sysctl -p /etc/sysctl.d/k8s.conf &>/dev/null
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
kubeadm config images pull --config init-default.yml

echo -e "\033[31m初始化...\033[0m"
kubeadm init --config init-default.yml
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
echo -e "\033[33mConfigMap如下:  \033[0m"
echo -e "\033[33m$(kubectl get -n kube-system configmaps)\033[0m"