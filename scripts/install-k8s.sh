echo -e "\033[32mGetting K8s...\033[0m"
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
net.bridge.bridge-nf-call-iptables=1
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

echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(kubeadm completion bash)" >> ~/.bashrc
source ~/.bashrc

echo -e "\033[32m是否安装etcd? (y/n)\033[0m"
read choose
if [ $choose="y" -o $choose="yes" -o $choose="Y" ];then
  yum install -y etcd
fi

systemctl enable kubelet && systemctl start kubelet
systemctl enable etcd && systemctl start etcd

echo -e "\033[32mDone\n\033[0m"