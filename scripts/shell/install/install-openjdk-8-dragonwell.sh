echo -e "\033[32mInstall Openjdk-8 Alibaba Dragonwell...\033[0m"
cat <<EOF > /etc/yum.repos.d/dragonwell.repo
[plus]
name=AliYun-2.1903 - Plus - mirrors.aliyun.com
baseurl=http://mirrors.aliyun.com/alinux/2.1903/plus/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/alinux/RPM-GPG-KEY-ALIYUN
EOF

yum install -y java-1.8.0-alibaba-dragonwell*

sed -i '/JAVA_HOME/d' /etc/profile
cat << EOF >> /etc/profile
export JAVA_HOME=/opt/alibaba/`rpm -qa | grep java-1.8.0-alibaba-dragonwell | grep -v 'debug' | sed 's/.x86_64//'`
export CLASS_PATH=.:${JAVA_HOME}/lib:${JAVA_HOME}/jre/lib
export PATH=${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:$PATH
EOF
source /etc/profile
java -version
javac -version
