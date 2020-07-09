# initialize k8s
echo -e "\033[33m输入k8s服务子网\033[0m"
read subnet
cat << EOF > init-default.yml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
imageRepository: registry.aliyuncs.com/google_containers
kubernetesVersion: v$(rpm -qa | grep kubectl | awk -F'-' '{print $2}')
networking:
  serviceSubnet: "$subnet"
EOF

echo -e "\033[32m开始拉取镜像...\033[0m"
kubeadm config images pull --config init-default.yml

echo -e "\033[32m初始化...\033[0m"
kubeadm init --config init-default.yml
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
echo -e "\033[32mConfigMap如下:\n$(kubectl get -n kube-system configmaps)\n\033[0m"