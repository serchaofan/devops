# set hostname
echo -e "\033[32Set hostname\033[0m"
read -p "input hostname: " hostname
hostnamectl set-hostname $hostname

# update yum source
echo -e "\033[32mUpdate yum source\033[0m"
yum install -y wget && rm -f /etc/yum.repos.d/*
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum makecache fast

# install lib
echo -e "\033[32minstall lib\033[0m"
yum groups mark install "Development Tools"
yum groups mark convert "Development Tools"
yum groups install -y "Development Tools"
yum install -y bash-completion vim


# close SELINUX and firewalld
echo -e "\033[32mclose SELINUX and firewalld\033[0m"
sed -i '/SELINUX=/c SELINUX=disabled' /etc/selinux/config
setenforce 0
systemctl disable firewalld
systemctl stop firewalld

