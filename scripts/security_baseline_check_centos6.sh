#!/bin/bash
echo -e "\033[32m---------------本脚本用于CentOS 6的安全基线检查---------------\033[0m"
echo -e "\033[32m本脚本对用户权限、文件权限、服务、日志、防火墙、DNS等的常见安全问题进行检查\033[0m"
echo -e "\033[32m修改日期：2020/7/6\n\033[0m"
echo -e "\033[32m开始检查.....\033[0m"
echo > /var/log/security_baseline_check.txt
echo -e "\033[32m当前主机名：$(hostname)\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m主机IP地址：\n$(ifconfig  | grep "inet" | grep -v 'inet6' | grep -v '127.0.0.1' | awk '{print $2}' | awk -F: '{print $2}')\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m当前CentOS版本：$(cat /etc/redhat-release | awk '{print $3}')\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m当前内核版本：$(uname -r)\n\033[0m" >> /var/log/security_baseline_check.txt

check_string_exists() {
	if [[ $(sed -n "/$1/p" $2) == '' ]];then
		echo -e "\033[31m✘ 文件:$2 \t检查项:\"$1\" \033[0m" >> /var/log/security_baseline_check.txt
	else
		echo -e "\033[32m√ 文件:$2 \t检查项:\"$1\" \033[0m" >> /var/log/security_baseline_check.txt
	fi
}

check_string_correct() {
	if [[ -e $3 ]];then		
		ConfigItem=$(sed -n "/$1/p" $3 | sed 's/^[ \t]*//g' | head -n1)
		if [[ $ConfigItem != $2 ]];then
			echo -e "\033[31m✘ 文件:$3 \t检查项:\"$1\" \t期望值:\"$2\"\033[0m" >> /var/log/security_baseline_check.txt
		else
			echo -e "\033[32m√ 文件:$3 \t检查项:\"$1\"\033[0m" >> /var/log/security_baseline_check.txt
		fi
	else
		echo -e "\033[31m✘ 文件:$3 \t 不存在\033[0m" >> /var/log/security_baseline_check.txt
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
            echo -e "\033[31m✘ 文件:$configfile \t检查项:\"$1\" \t期望值:\"$2\"\033[0m" >> /var/log/security_baseline_check.txt
        else
            echo -e "\033[32m√ 文件:$configfile \t检查项:\"$1\"\033[0m" >> /var/log/security_baseline_check.txt
        fi
    else 
        echo -e "\033[31m✘ 文件:$configfile \t检查项:\"$1\" \t期望值:\"$2\"\033[0m" >> /var/log/security_baseline_check.txt
    fi
}

check_file_perm() {
	file=$1
	perm_expect=$2
	if [ -e $file ];then	
		perm=$(stat -c %a $file)
		if [ $perm -gt $perm_expect ];then
			echo -e "\033[31m✘ File:$file\t期望权限值:\"$2\" \033[0m" >> /var/log/security_baseline_check.txt
		else
			echo -e "\033[32m√ File:$file\t当前权限值: $perm\033[0m" >> /var/log/security_baseline_check.txt
		fi
	else
		echo -e "\033[31m✘ File:$file 文件不存在. PASS\033[0m" >> /var/log/security_baseline_check.txt
	fi
}

check_service_down() {
	for service in $@;do
		if [[ $(ls -l /etc/init.d/ | grep $service) != '' ]];then
			if [[ $(/etc/init.d/$service status | grep 'running' | awk '{print $1}') == $service ]];then
				echo -e "\033[31m✘ $service 正在运行 \033[0m" >> /var/log/security_baseline_check.txt
			else
				echo -e "\033[32m√ $service 未启动 \033[0m" >> /var/log/security_baseline_check.txt
			fi
		else
			echo -e "\033[32m√ $service 服务不存在.\033[0m" >> /var/log/security_baseline_check.txt
		fi
	done
}


list_user_extra() {
	echo -e "\033[32m非自建用户（uid>=500） \033[0m" >> /var/log/security_baseline_check.txt
	echo -e "\033[32m$(awk -F':' '{if($3 >= 500) print $1,$3,$7}' /etc/passwd) \033[0m" >> /var/log/security_baseline_check.txt
	
}

echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.1.2.	口令复杂度和生存周期\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m口令策略的配置长度、复杂度安全要求\033[0m" >> /var/log/security_baseline_check.txt
check_string_exists "password required pam_pwquality.so retry=3" /etc/pam.d/passwd 
check_string_exists "password required pam_pwquality.so dcredit=-1 ucredit=-1 ocredit=-1 lcredit=0 minlen=8" /etc/pam.d/system-auth
echo -e "\n" >> /var/log/security_baseline_check.txt
check_string_correct "minlen" "minlen = 8" /etc/security/pwquality.conf
check_string_correct "dcredit" "dcredit = -1" /etc/security/pwquality.conf
check_string_correct "ucredit" "ucredit = -1" /etc/security/pwquality.conf
check_string_correct "ocredit" "ocredit = -1" /etc/security/pwquality.conf
check_string_correct "lcredit" "lcredit = 0" /etc/security/pwquality.conf
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m口令生存周期\033[0m" >> /var/log/security_baseline_check.txt
check_string_correct "PASS_MAX_DAYS" "PASS_MAX_DAYS 90" /etc/login.defs
check_string_correct "PASS_WARN_AGE" "PASS_WARN_AGE 7" /etc/login.defs
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m不能复用的密码个数\033[0m" >> /var/log/security_baseline_check.txt
check_string_exists "password required pam_unix.so remember=5 use_authtok md5 shadow" /etc/pam.d/passwd
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.1.3.	账户锁定\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m登录失败处理功能\033[0m" >> /var/log/security_baseline_check.txt
check_string_exists "auth required pam_tally2.so deny=3 unlock_time=300 even_deny_root root_unlock_time=10" /etc/pam.d/sshd
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m禁用默认账号\033[0m"  >> /var/log/security_baseline_check.txt
check_string_exists '\/bin\/false' /etc/shells
echo -e "\033[33m确认以下账号的权限为/bin/false\033[0m"  >> /var/log/security_baseline_check.txt
for user in ftp sync nobody games;do
	echo -e "\033[33m$(grep ^$user /etc/passwd | awk -F':' '{print $1,$3,$7}')\033[0m" >> /var/log/security_baseline_check.txt
done
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.2.1.	敏感文件权限最小化\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m检查文件与目录权限\033[0m" >> /var/log/security_baseline_check.txt
check_file_perm /etc/passwd 644
check_file_perm /etc/shadow 600
check_file_perm /etc/rc3.d 644
check_file_perm /etc/profile 644
check_file_perm /etc/inet.conf 644
check_file_perm /etc/xinet.conf 750
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.2.2.	权限分离\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m操作系统和数据库系统特权用户的权限分离\033[0m" >> /var/log/security_baseline_check.txt
check_string_correct 'pam_wheel.so use_uid' 'auth required pam_wheel.so use_uid' /etc/pam.d/su
check_string_exists "SU_WHEEL_ONLY yes" /etc/login.defs
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.3.1.	审计内容要求\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m检查rsyslog配置\033[0m" >> /var/log/security_baseline_check.txt
check_rsyslog 'mail.\*' '-/var/log/maillog'
check_rsyslog 'authpriv.\*' '/var/log/secure'
check_rsyslog 'cron.\*' '/var/log/cron'
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.3.2.	审计内容存储与保护\033[0m" >> /var/log/security_baseline_check.txt
check_rsyslog '\*.\*' "@@*:514"
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.4.1.	最小安装原则和补丁更新\033[0m" >> /var/log/security_baseline_check.txt
check_service_down printer tftp lpd nfs-server nfs-lock ypbind daytime nginx sendmail ntalk ident bootps kshell klogin
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.4.2.	禁止root远程登录\033[0m" >> /var/log/security_baseline_check.txt
check_string_correct "PermitRootLogin" "PermitRootLogin yes" /etc/ssh/sshd_config
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.4.3.	启用防火墙\033[0m" >> /var/log/security_baseline_check.txt
if [[ $(ps -ef | grep iptables | grep -v 'grep') != '' ]];then
	echo -e "\033[31m✘ Iptables正在运行 \033[0m" >> /var/log/security_baseline_check.txt
else
	echo -e "\033[32m√ Iptables未启动 \033[0m" >> /var/log/security_baseline_check.txt
fi

echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.5.1.	限制终端登录\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32mhosts.allow:\n$(cat /etc/hosts.allow | grep -v '^#')\n\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32mhosts.deny:\n$(cat /etc/hosts.deny | grep -v '^#')\n\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.5.2.	超时锁定\033[0m" >> /var/log/security_baseline_check.txt
check_string_exists "TIMEOUT" /etc/profile
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.5.3.	系统时间同步\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m当前ntpserver:\n$(grep 'nameserver' /etc/ntp.conf | grep -v '^#')\n\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m2.5.4.	配置企业内部DNS\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\033[32m当前nameserver:\n$(grep 'nameserver' /etc/resolv.conf)\n\033[0m" >> /var/log/security_baseline_check.txt
echo -e "\n" >> /var/log/security_baseline_check.txt
list_user_extra
echo -e "\n" >> /var/log/security_baseline_check.txt
echo -e "\033[32m检查结束，请在/var/log/security_baseline_check.txt查看输出结果\033[0m"