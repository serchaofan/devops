# initialize k8s
echo -e "\033[32m输入k8s服务子网\033[0m"
read -p "Input Subnet: " subnet

echo -e "\033[32m当前Kubectl版本： v$(rpm -qa | grep kubectl | awk -F'-' '{print $2}')\033[0m"
echo -e "\033[32m请填入要部署的k8s版本（一定要小于等于kubectl版本，只填数字）\033[0m"
read -p "Input Version: " version
cat << EOF > init-default.yml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
imageRepository: registry.aliyuncs.com/google_containers
kubernetesVersion: v${version}
networking:
  serviceSubnet: "${subnet}"
EOF

echo -e "\033[32m开始拉取镜像...\033[0m"
kubeadm config images pull --config init-default.yml &> /dev/null

echo -e "\033[32m初始化...\033[0m"
kubeadm init --config init-default.yml
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
echo -e "\033[32mConfigMap如下:\n$(kubectl get -n kube-system configmaps)\n\033[0m"