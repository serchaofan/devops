yum groups install -y Development\ Tools
yum install -y libffi-devel openssl-devel
curl -L https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tgz -o ~/Python-3.8.2.tgz && tar -xzf ~/Python-3.8.2.tgz -C ~/python38
cd python38 && ./configure --prefix=/usr/local/python38 && make && make install &>/dev/null