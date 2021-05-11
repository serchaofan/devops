echo -e "\033[32mInstall Openjdk-11...\033[0m"
yum install -y java-11-openjdk-devel java-11-openjdk java-11-openjdk-headless

sed -i '/JAVA_HOME/d' /etc/profile
cat << EOF >> /etc/profile
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export CLASS_PATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/jre/lib
export PATH=\${JAVA_HOME}/bin:\${JAVA_HOME}/jre/bin:\$PATH
EOF
source /etc/profile
java -version
javac -version
