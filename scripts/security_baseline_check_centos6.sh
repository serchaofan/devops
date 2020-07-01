#!/bin/bash

check_string_exists() {
	if [[ $(sed -n "/$1/p" $2) == '' ]];then
		echo -e "\033[31m✘ 文件:$2 \t检查项:\"$1\" \033[0m"
	else
		echo -e "\033[32m√ 文件:$2 \t检查项:\"$1\" \033[0m"
	fi
}

check_string_correct() {
	if [[ -e $3 ]];then		
		ConfigItem=$(sed -n "/$1/p" $3 | sed 's/^[ \t]*//g' | head -n1)
		if [[ $ConfigItem != $2 ]];then
			echo -e "\033[31m✘ 文件:$3 \t检查项:\"$1\" \t期望值:\"$2\"\033[0m"
		else
			echo -e "\033[32m√ 文件:$3 \t检查项:\"$1\"\033[0m"
		fi
	else
		echo -e "\033[31m✘ 文件:$3 \t 不存在\033[0m"
	fi
}

check_rsyslog() {
    configfile="/etc/rsyslog.conf"
    item=$1
    item_val_expect=$2
    item_line=$(sed -n "/$item/p" $configfile)
    if [[ ${item_line:0:1} != '#' ]];then
        item_val=$(echo $item_line | awk '{print $2}')
        if [[ $item_val != $item_val_expect ]];then
            echo -e "\033[31m✘ 文件:$configfile \t检查项:\"$1\" \t期望值:\"$2\"\033[0m"
        else
            echo -e "\033[32m√ 文件:$configfile \t检查项:\"$1\"\033[0m"
        fi
    else 
        echo -e "\033[31m✘ 文件:$configfile \t检查项:\"$1\" \t期望值:\"$2\"\033[0m"
    fi
}

check_file_perm() {
	file=$1
	perm_expect=$2
	if [ -e $file ];then	
		perm=$(stat -c %a $file)
		if [ $perm -gt $perm_expect ];then
			echo -e "\033[31m✘ File:$file\t期望权限值:\"$2\" \033[0m"
		else
			echo -e "\033[32m√ File:$file\t当前权限值: $perm\033[0m"
		fi
	else
		echo -e "\033[31m✘ File:$file 文件不存在. PASS\033[0m"
	fi
}

check_service_down() {
	for service in $@;do
		if [[ $(ls -l /etc/init.d/ | grep $service) != '' ]];then
			if [[ $(/etc/init.d/$service status | grep 'running' | awk '{print $1}') == $service ]];then
				echo -e "\033[31m✘ $service 正在运行 \033[0m"
			else
				echo -e "\033[32m√ $service 未启动 \033[0m"
			fi
		else
			echo -e "\033[32m√ $service 服务不存在.\033[0m"
		fi
	done
}


list_user_extra() {
	echo -e "\033[32m非自建用户（uid>=500） \033[0m"
	echo -e "\033[32m$(awk -F':' '{if($3 >= 500) print $1,$3,$7}' /etc/passwd) \033[0m"
	
}

echo -e "\033[32m2.1.2.	口令复杂度和生存周期\033[0m"
echo -e "\033[32m口令策略的配置长度、复杂度安全要求\033[0m"
check_string_exists "password required pam_pwquality.so retry=3" /etc/pam.d/passwd 
check_string_exists "password required pam_pwquality.so dcredit=-1 ucredit=-1 ocredit=-1 lcredit=0 minlen=8" /etc/pam.d/system-auth

check_string_correct "minlen" "minlen = 8" /etc/security/pwquality.conf
check_string_correct "dcredit" "dcredit = -1" /etc/security/pwquality.conf
check_string_correct "ucredit" "ucredit = -1" /etc/security/pwquality.conf
check_string_correct "ocredit" "ocredit = -1" /etc/security/pwquality.conf
check_string_correct "lcredit" "lcredit = 0" /etc/security/pwquality.conf

echo -e "\033[32m口令生存周期\033[0m"
check_string_correct "PASS_MAX_DAYS" "PASS_MAX_DAYS 90" /etc/login.defs
check_string_correct "PASS_WARN_AGE" "PASS_WARN_AGE 7" /etc/login.defs

echo -e "\033[32m不能复用的密码个数\033[0m"
check_string_exists "password required pam_unix.so remember=5 use_authtok md5 shadow" /etc/pam.d/passwd

echo -e "\033[32m2.1.3.	账户锁定\033[0m"
echo -e "\033[32m登录失败处理功能\033[0m"
check_string_exists "auth required pam_tally2.so deny=3 unlock_time=300 even_deny_root root_unlock_time=10" /etc/pam.d/sshd

echo -e "\033[32m2.2.1.	敏感文件权限最小化\033[0m"
echo -e "\033[32m检查文件与目录权限\033[0m"
check_file_perm /etc/passwd 644
check_file_perm /etc/shadow 600
check_file_perm /etc/rc3.d 644
check_file_perm /etc/profile 644
check_file_perm /etc/inet.conf 644
check_file_perm /etc/xinet.conf 750

echo -e "\033[32m2.2.2.	权限分离\033[0m"
echo -e "\033[32m操作系统和数据库系统特权用户的权限分离\033[0m"
check_string_correct 'pam_wheel.so use_uid' 'auth required pam_wheel.so use_uid' /etc/pam.d/su
check_string_exists "SU_WHEEL_ONLY yes" /etc/login.defs

echo -e "\033[32m2.3.1.	审计内容要求\033[0m"
echo -e "\033[32m检查rsyslog配置\033[0m"
check_rsyslog 'mail.\*' '-/var/log/maillog'
check_rsyslog 'authpriv.\*' '/var/log/secure'
check_rsyslog 'cron.\*' '/var/log/cron'

echo -e "\033[32m2.3.2.	审计内容存储与保护\033[0m"
check_rsyslog '\*.\*' "@@*:514"

echo -e "\033[32m2.4.1.	最小安装原则和补丁更新\033[0m"
check_service_down printer tftp lpd nfs-server nfs-lock ypbind daytime nginx sendmail ntalk ident bootps kshell klogin

echo -e "\033[32m2.4.2.	禁止root远程登录\033[0m"
check_string_correct "PermitRootLogin" "PermitRootLogin yes" /etc/ssh/sshd_config

echo -e "\033[32m2.4.3.	启用防火墙\033[0m"
if [[ $(ps -ef | grep iptables | grep -v 'grep') != '' ]];then
	echo -e "\033[31m✘ Iptables正在运行 \033[0m"
else
	echo -e "\033[32m√ Iptables未启动 \033[0m"
fi


echo -e "\033[32m2.5.1.	限制终端登录\033[0m"
echo -e "\033[32mhosts.allow:\n$(cat /etc/hosts.allow | grep -v '^#')\n\033[0m"
echo -e "\033[32mhosts.deny:\n$(cat /etc/hosts.deny | grep -v '^#')\n\033[0m"

echo -e "\033[32m2.5.2.	超时锁定\033[0m"
check_string_exists "TIMEOUT" /etc/profile

echo -e "\033[32m2.5.3.	系统时间同步\033[0m"
echo -e "\033[32m当前ntpserver:\n$(grep 'nameserver' /etc/ntp.conf | grep -v '^#')\n\033[0m"

echo -e "\033[32m2.5.4.	配置企业内部DNS\033[0m"
echo -e "\033[32m当前nameserver:\n$(grep 'nameserver' /etc/resolv.conf)\n\033[0m"

list_user_extra