#!/bin/bash

check_string_exists() {
	if [[ $(sed -n "/$1/p" $2) == '' ]];then
		echo -e "\033[31mConfigFile:$2 \tConfigItem:\"$1\" ✘\033[0m"
	else
		echo -e "\033[32mConfigFile:$2 \tConfigItem:\"$1\" √\033[0m"
	fi
}

check_string_correct() {
	ConfigItem=$(sed -n "/$1/p" $3 | sed 's/^[ \t]*//g' | head -n1)
	if [[ $ConfigItem != $2 ]];then
		echo -e "\033[31mConfigFile:$3 \tConfigItem:\"$1\" \tExpected:\"$2\"\033[0m"
	else
		echo -e "\033[32mConfigFile:$3 \tConfigItem:\"$1\"\033[0m"
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
            echo -e "\033[31mConfigFile:$configfile \tConfigItem:\"$1\" \tExpected:\"$2\"\033[0m"
        else
            echo -e "\033[32mConfigFile:$configfile \tConfigItem:\"$1\"\033[0m"
        fi
    else
        echo -e "\033[31mConfigFile:$configfile \tConfigItem:\"$1\" \tExpected:\"$2\"\033[0m"
    fi
}


check_file_perm() {
	file=$1
	perm_expect=$2
	if [ -e $file ];then	
		perm=$(stat -c %a $file)
		if [ $perm -gt $perm_expect ];then
			echo -e "\033[31mFile:$file\tExpected:\"$2\" ✘\033[0m"
		else
			echo -e "\033[32mFile:$file\t √\033[0m"
		fi
	else
		echo -e "\033[31mFile:$file Doesn't Exists. PASS\033[0m"
	fi
}

check_service_down() {
	for service in $@;do
		service=$service".service"
		if [[ $(systemctl list-unit-files | grep $service) != '' ]];then
			is_enabled=$(systemctl list-unit-files | grep $service | awk '{print $2}')
			is_active=$(systemctl list-units | grep $service | awk '{print $3}')
			if [[ ${is_active} == 'active' ]];then
				echo -e "\033[31m$service Is Running and $is_enabled ✘\033[0m"
			else
				echo -e "\033[32m$service Is Down and $is_enabled √\033[0m"
			fi
		else
			echo -e "\033[32m$service Doesn't Exists.√\033[0m"
		fi
	done
}

check_string_exists "password required pam_pwquality.so retry=3" /etc/pam.d/passwd 
check_string_exists "password required pam_pwquality.so dcredit=-1 ucredit=-1 ocredit=-1 lcredit=0 minlen=8" /etc/pam.d/system-auth

check_string_correct "minlen" "minlen = 8" /etc/security/pwquality.conf
check_string_correct "dcredit" "dcredit = -1" /etc/security/pwquality.conf
check_string_correct "ucredit" "ucredit = -1" /etc/security/pwquality.conf
check_string_correct "ocredit" "ocredit = -1" /etc/security/pwquality.conf
check_string_correct "lcredit" "lcredit = 0" /etc/security/pwquality.conf

check_string_correct "PASS_MAX_DAYS" "PASS_MAX_DAYS 90" /etc/login.defs
check_string_correct "PASS_WARN_AGE" "PASS_WARN_AGE 7" /etc/login.defs
check_string_exists "password required pam_unix.so remember=5 use_authtok md5 shadow" /etc/pam.d/passwd
check_string_exists "auth required pam_tally2.so deny=3 unlock_time=300 even_deny_root root_unlock_time=10" /etc/pam.d/sshd

check_file_perm /etc/passwd 644
check_file_perm /etc/shadow 600
check_file_perm /etc/rc3.d 644
check_file_perm /etc/profile 644
check_file_perm /etc/inet.conf 644
check_file_perm /etc/xinet.conf 750

check_string_correct 'pam_wheel.so use_uid' 'auth required pam_wheel.so use_uid' /etc/pam.d/su
check_string_exists "SU_WHEEL_ONLY yes" /etc/login.defs

check_rsyslog 'mail.\*' '-/var/log/maillog'
check_rsyslog 'authpriv.\*' '/var/log/secure'
check_rsyslog 'cron.\*' '/var/log/cron'
check_rsyslog '\*.\*' "@@*:514"

check_service_down printer tftp lpd nfs-server nfs-lock ypbind daytime nginx sendmail ntalk ident bootps kshell klogin

check_string_correct "PermitRootLogin" "PermitRootLogin yes" /etc/ssh/sshd_config

if [[ $(systemctl is-active firewalld) == 'active' ]];then
	echo -e "\033[31m$service Is Running ✘\033[0m"
else
	echo -e "\033[32m$service Is Down √\033[0m"
fi

check_string_exists "TIMEOUT" /etc/profile

echo -e "\033[32mhosts.allow:\n$(cat /etc/hosts.allow | grep -v '^#')\n\033[0m"
echo -e "\033[32mhosts.deny:\n$(cat /etc/hosts.deny | grep -v '^#')\n\033[0m"
echo -e "\033[32m当前ntpserver:\n$(grep 'nameserver' /etc/chrony.conf | grep -v '^#')\n\033[0m"
echo -e "\033[32m当前nameserver:\n$(grep 'nameserver' /etc/resolv.conf)\n\033[0m"
