# install mysql repo
rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm


cat << EOF > /etc/yum.repos.d/mysql-community.repo
[mysql-connectors-community]
name=MySQL Connectors Community
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-connectors-community-el7-\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql

[mysql-tools-community]
name=MySQL Tools Community
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-tools-community-el7-\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql

[mysql-5.7-community]
name=MySQL 5.7 Community Server
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-5.7-community-el7-\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql
EOF

yum makecache fast
yum install --skip-broken -y \
    mysql-community-client \
    mysql-community-common \
    mysql-community-devel \
    mysql-community-embedded \
    mysql-community-embedded-compat \
    mysql-community-embedded-devel \
    mysql-community-libs \
    mysql-community-libs-compat \
    mysql-community-server

systemctl start mysqld
sleep 5
TEMP_PASSWD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
echo "TEMP PASSWORD: ${TEMP_PASSWD}"
mysqladmin -uroot -p'${TEMP_PASSWD}' password 'yINJI@2021!'