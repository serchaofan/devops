yum groups mark install "Development Tools"
yum groups mark convert "Development Tools"
yum groups install -y "Development Tools"
yum install -y gcc
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel
curl -L https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tgz -o ~/Python-3.8.9.tgz && tar -xzf ~/Python-3.8.9.tgz
cd ~/Python-3.8.9 && ./configure && make && make install
mkdir -p ~/.pip
cat << EOF > ~/.pip/pip.conf
[global]
trusted-host=mirrors.aliyun.com
index-url=https://mirrors.aliyun.com/pypi/simple
EOF

pip3 install -U pip
sleep 3

checkPath=`echo $PATH | sed '\/usr\/local\/bin/p' -n | wc -l`
if [[ "$checkPath" == 0 ]];then
  echo "export PATH=/usr/local/bin:\$PATH" >> /etc/profile
  source /etc/profile
  echo "$PATH"
elif [[ "$checkPath" == 1 ]];then
  echo "$PATH"
fi

wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py

PYTHON_VER=$(python3 --version | awk -F" " '{print $2}')
PIP_VER=$(pip3 --version | awk -F" " '{print $2}')
echo -e "\033[32m
Python版本： $PYTHON_VER
Pip版本： $PIP_VER
\033[0m"