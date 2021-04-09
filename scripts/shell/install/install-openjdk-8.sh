echo -e "\033[32mInstall Openjdk-8...\033[0m"
yum install -y java-1.8.0-openjdk-devel java-1.8.0-openjdk java-1.8.0-openjdk-headless

sed -i '/JAVA_HOME/d' /etc/profile
cat << EOF >> /etc/profile
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
export CLASS_PATH=.:${JAVA_HOME}/lib:${JAVA_HOME}/jre/lib
export PATH=${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:$PATH
EOF
source /etc/profile
java -version
javac -version
