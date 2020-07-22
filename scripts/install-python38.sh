yum groups mark install "Development Tools"
yum groups mark convert "Development Tools"
yum groups install -y "Development Tools"
yum install -y libffi-devel openssl-devel
curl -L https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tgz -o ~/Python-3.8.2.tgz && tar -xzf ~/Python-3.8.2.tgz
cd ~/Python-3.8.2 && ./configure && make && make install
mkdir ~/.pip
cat << EOF > ~/.pip/pip.conf
[global]
trusted-host=mirrors.aliyun.com
index-url=https://mirrors.aliyun.com/pypi/simple 
EOF

pip3 install -U pip
PYTHON_VER=$(python3 --version | awk -F" " '{print $2}')
PIP_VER=$(pip3 --version | awk -F" " '{print $2}')
echo -e "\033[32m
Python版本： $PYTHON_VER
Pip版本： $PIP_VER
\033[0m"