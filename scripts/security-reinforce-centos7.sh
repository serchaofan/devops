#!/bin/bash

CHRONY_SERVER=192.168.3.100
DNS_SERVER=192.168.3.100

chown root:root /etc/passwd /etc/shadow /etc/group /etc/gshadow
chmod 0644 /etc/group
chmod 0644 /etc/passwd
chmod 000 /etc/shadow
chmod 000 /etc/gshadow

chmod 600 /var/log/boot.log

sed -i '/sync/s/\/bin\/sync/\/sbin\/nologin/g' /etc/passwd

sed -i '/umask/s/022/027/g' /etc/bashrc

sed -i '/PASS_MAX_DAYS/s/99999/90/g' /etc/login.defs

[ -z $(grep 'pam_stack.so' /etc/pam.d/passwd) ] && {
cat  << EOF >> /etc/pam.d/passwd
password   requisite    pam_pwquality.so  retry=5  minlen=8 lcredit=-1 ucredit=-1 ocredit=-1 dcredit=-1   pam_stack.so
password   include      system-auth
EOF
}

[ -z $(grep 'pam_faillock.so' /etc/pam.d/system-auth) ] && {
cat << EOF >> /etc/pam.d/system-auth
auth        required          pam_faillock.so    preauth    silent   audit deny=5 even_deny_root unlock_time=1800
auth        sufficient        pam_unix.so        nullok     try_first_pass
auth        [default=die]     pam_faillock.so    authfail   audit deny=5 even_deny_root unlock_time=1800
account     required          pam_faillock.so
EOF
}

[ -z $(grep 'pam_faillock.so' /etc/pam.d/password-auth) ] && {
cat << EOF >> /etc/pam.d/password-auth
auth        required      pam_faillock.so preauth silent audit deny=5 even_deny_root unlock_time=1800
auth        sufficient    pam_unix.so nullok try_first_pass
auth        [default=die] pam_faillock.so authfail audit deny=5 even_deny_root unlock_time=1800
account     required      pam_faillock.so
EOF
}

[ -z $(grep 'TIMEOUT' /etc/profile) ] && {
cat << EOF >> /etc/profile
export TIMEOUT=1800
EOF
}

yum install -y chrony
systemctl start chronyd

sed -i "/centos.pool/d" /etc/chrony.conf
sed -i  '3 i server $CHRONY_SERVER iburst;' /etc/chrony.conf
systemctl restart chronyd
systemctl enable chronyd

sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -p
# systemctl stop firewalld
# systemctl disable firewalld
# yum install -y iptables-services
# systemctl start iptables
# systemctl enable iptables

# cat << EOF > /etc/sysconfig/iptables
# *filter
# :INPUT DROP [0:0]
# :FORWARD ACCEPT [0:0]
# :OUTPUT ACCEPT [0:0]
# -A INPUT -s 192.0.19.201 -p tcp -m tcp --dport 22 -j ACCEPT
# -A INPUT -s 192.0.68.0/255.255.255.0 -p tcp -m tcp --dport 22 -j ACCEPT
# -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# -A INPUT -p icmp -j ACCEPT
# -A INPUT -i lo -j ACCEPT
# COMMIT
# EOF
# systemctl restart iptables

cat << EOF > /etc/resolv.conf
nameserver $DNS_SERVER
EOF

sed -i '/PermitRootLogin/s/yes/no/g' /etc/ssh/sshd_config

# cat << EOF >> /etc/hosts.deny
# sshd:all:deny
# EOF

# cat << EOF >> /etc/hosts.allow
# sshd:127.0.0.1:allow
# sshd:192.0.19.201:allow
# sshd:192.0.69.76:allow
# sshd:192.0.69.220:allow
# sshd:192.0.68.*:allow
# EOF
