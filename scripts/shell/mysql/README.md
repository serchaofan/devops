- [mysqld自动补全脚本](./mysqld.bash)
- [mysqld启动脚本](./mysqld.sh)

在使用ansible安装完二进制mysql后，将mysqld.sh剪切成/usr/sbin/mysqld，添加执行权限，需要修改脚本中用户名或密码
然后添加自动补全，将mysqld.bash放在/etc/bash_completion.d/mysqld.bash，source这个文件。若要开机自动添加，则写到/etc/profile里。