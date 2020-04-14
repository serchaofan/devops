yum groups install -y Development\ Tools
yum install -y libffi-devel openssl-devel
curl -L https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tgz -o ~/Python-3.8.2.tgz && tar -xzf ~/Python-3.8.2.tgz
cd ~/Python-3.8.2 && ./configure && make && make install
echo -e "\033[31mPython版本：$(python3 --version)\033[0m"