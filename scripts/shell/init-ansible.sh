#!/bin/bash

USER=root
PASSWD=yINJI@2020!
REMOTE_IP_PRE="10.193.1."
HOSTNUM_START=21
HOSTNUM_END=27

wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum install -y ansible
yum install -y expect

[[ ! -f ~/.ssh/id_rsa.pub ]] && {
cat << EOF > ~/ssh-keygen.exp
#!/usr/bin/expect
spawn ssh-keygen
  expect {
  	"Enter file" {
  		send "\n"
  		expect "Enter passphrase" {
  			send "\n"
  			expect "Enter same passphrase" {
  				send "\n"
  			}
  		}
  	}
  }
}
expect eof
EOF
chmod +x ~/ssh-keygen.exp
~/ssh-keygen.exp &> /dev/null
rm -f ~/ssh-keygen.exp

cat << EOF > ~/ssh-copy-id.exp
#!/usr/bin/expect
set timeout 10
set userhost [lindex \$argv 0]
set passwd [lindex \$argv 1]
spawn ssh-copy-id \$userhost
  expect {
  	"(yes/no)?" {
  		send "yes\n"
  		expect "*assword:" {
  			send "\$passwd\n"
  		}
  	}
  	"*assword:" {
  		send "\$passwd\n"
  	}
  }
expect eof
EOF
chmod +x ~/ssh-keygen.exp

for num in {\$HOSTNUM_START..\$HOSTNUM_END}
do
	host=\${REMOTE_IP_PRE}\${num}
	~/ssh-copy-id.exp \${USER}@\${host} \${PASSWD}
done
rm -f ~/ssh-copy-id.exp
