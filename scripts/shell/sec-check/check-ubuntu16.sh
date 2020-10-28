#!/bin/bash


LOGFILE=/var/log/baseline_check.txt
SUGFILE=/var/log/suggestions.txt
echo > $LOGFILE
echo > $SUGFILE

RED="$(printf '\033[1;31m')"
YELLOW="$(printf '\033[1;33m')"
GREEN="$(printf '\033[1;32m')"
NORMAL="$(printf '\033[0m')"

Display() {
    COLOR=""; RESULT=""; TEXT=""; RESULTPART="";
    while [ $# -ge 1 ];do
        case $1 in
            --color)
                shift
                case $1 in
                    GREEN)   COLOR=$GREEN   ;;
                    RED)     COLOR=$RED     ;;
                    WHITE)   COLOR=$WHITE   ;;
                    YELLOW)  COLOR=$YELLOW  ;;
                esac
            ;;
            --result)
                shift
                RESULT=$1
            ;;
            --text)
                shift
                TEXT=$1
            ;;
        esac
        shift
    done
    if [ -z "${RESULT}" ]; then
        RESULTPART=""
        echo "${TEXT}" | tee -a $LOGFILE
    else
        RESULTPART=" [ ${COLOR}${RESULT}${NORMAL} ]"
        LINESIZE=$(echo "${TEXT}" | wc -m | tr -d ' ')
        SPACES=$((80 - LINESIZE))
        echo "\033[0C${TEXT}\033[${SPACES}C${RESULTPART}" | tee -a $LOGFILE
    fi
}

################################################################################

Display --text "==================本脚本用于Ubuntu 16的安全基线检查=================="
Display --text "本脚本对用户权限、文件权限、服务、日志、防火墙、DNS等的常见安全问题进行检查"
Display --text "修改日期：2020/10/27"
Display --text "开始检查....."

################################################################################


Display --text "====================================================================="
Display --text "Hostname:            $(hostname)"
Display --text "IP Addr:             $(ifconfig | grep 'inet\ ' | awk '{print $2}' | awk -F: '{print $2}' | grep -Ev '^127|^172')"
Display --text "Ubuntu:              $(cat /etc/issue.net | awk '{print $2}')"
Display --text "Kernel:              $(uname -r)"
Display --text "====================================================================="


CheckExists() {
    if [[ $(sed -n "/$1/p" $2) == '' ]];then
        Display --text "$2   $1" --result "NotExists" --color RED
    else
        Display --text "$2   $1" --result "Exists" --color GREEN
    fi
}

CheckCorrect() {
    if [[ -e $3 ]];then
        ConfigItem=$(sed -n "/$1/p" $3 | sed 's/^[ \t]*//g' | head -n1)
        if [[ $ConfigItem != $2 ]];then
            Display --text "$3   $1" --result "NotFit" --color RED
            echo "配置值错误\t$3  $1 (exp: $2)" >>  $SUGFILE
        else
            Display --text "$3   $1" --result "OK" --color GREEN
        fi
    else
        Display --text "$3" --result "NotExists" --color RED
        echo "配置值错误\t$3  (exp: $2)" >>  $SUGFILE
    fi
}

CheckRsyslog() {
    configfile="/etc/rsyslog.d/50-default.conf"
    item=$1
    item_val_expect=$2
    item_line=$(sed -n "/$item/p" $configfile)
    if [[ ${item_line:0:1} != '#' ]];then
        item_val=$(echo $item_line | awk '{print $2}')
        if [[ $item_val != $item_val_expect ]];then
            Display --text "$configfile  $1" --result "NotFit" --color RED
            echo "Rsyslog配置\t$configfile (exp:$2)" >>  $SUGFILE
        else
            Display --text "$configfile  $1" --result "OK" --color GREEN
        fi
    else
        Display --text "$configfile  $1 (exp:$2)" --result "NotFit" --color RED
        echo "Rsyslog配置\t$configfile  $1 (exp:$2)" >>  $SUGFILE
    fi
}

CheckPerm() {
    file=$1
    perm_expect=$2
    if [ -e ${file} ];then
        perm=$(stat -c %a ${file})
        if [ ${perm} -gt ${perm_expect} ];then
            Display --text "${file}  ${perm}" --result "NotFit" --color RED
            echo "文件权限\t${file} (exp:${perm_expect})" >> $SUGFILE
        else
            Display --text "${file}  ${perm}" --result "OK" --color GREEN
        fi
    else
        Display --text "$file" --result "NotExists" --color RED
        echo "文件权限\t${file}  $1 (exp:${perm_expect})" >> $SUGFILE
    fi
}

CheckServDown() {
    for service in $@;do
        service=$service".service"
        if [[ $(systemctl list-unit-files | grep $service) != '' ]];then
            is_enabled=$(systemctl list-unit-files | grep $service | awk '{print $2}')
            is_active=$(systemctl list-units | grep $service | awk '{print $3}')
            if [[ ! -z ${is_active} ]];then
                if [[ ${is_active} == 'active' ]];then
                    Display --text "$service" --result "$is_active | $is_enabled" --color YELLOW
                else
                    Display --text "$service" --result "$is_active | $is_enabled" --color GREEN
                fi
            else
                Display --text "$service" --result "NotExists" --color GREEN
            fi
        else
            Display --text "$service" --result "NotExists" --color GREEN
        fi
    done
}

ListUserExtra() {
    Display --text "非自建用户（uid>=500）"
    Display --text "$(awk -F':' '{if($3 >= 500) print $1,$3,$7}' /etc/passwd)"
}

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.1.2.口令复杂度和生存周期"
Display --text "[+] 口令策略的配置长度、复杂度安全要求"
CheckExists "password required pam_pwquality.so retry=3" /etc/pam.d/common-password
CheckCorrect "minlen" "minlen = 8" /etc/security/pwquality.conf
CheckCorrect "dcredit" "dcredit = -1" /etc/security/pwquality.conf
CheckCorrect "ucredit" "ucredit = -1" /etc/security/pwquality.conf
CheckCorrect "ocredit" "ocredit = -1" /etc/security/pwquality.conf
CheckCorrect "lcredit" "lcredit = 0" /etc/security/pwquality.conf

Display --text "====================================================================="
Display --text "[+] 口令生存周期"
CheckCorrect "PASS_MAX_DAYS" "PASS_MAX_DAYS 90" /etc/login.defs
CheckCorrect "PASS_WARN_AGE" "PASS_WARN_AGE 7" /etc/login.defs
Display --text "[+] 不能复用的密码个数"
CheckExists "password required pam_pwhistory.so remember=5" /etc/pam.d/common-password

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.1.3.账户锁定"
Display --text "[+] 登录失败处理功能"
CheckExists "auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=1800" /etc/pam.d/common-auth
Display --text "[+] 禁用默认账号"
CheckExists '\/bin\/false' /etc/shells
Display --text "[+] 确认以下账号的权限为"
for user in ftp sync nobody games;do
    Display --text "$(grep ^$user /etc/passwd | awk -F':' '{print $1,$3,$7}')"
done

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.2.1.敏感文件权限最小化"
Display --text "[+] 检查文件与目录权限"
CheckPerm /etc/passwd 644
CheckPerm /etc/shadow 600
CheckPerm /etc/group 644
CheckPerm /etc/gshadow 600
CheckPerm /etc/passwd- 644
CheckPerm /etc/shadow- 600
CheckPerm /etc/group- 644
CheckPerm /etc/gshadow- 600
CheckPerm /etc/init.d 750
CheckPerm /etc/profile 644
CheckPerm /etc/inet.conf 644
CheckPerm /etc/xinet.conf 750

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.2.2.权限分离"
Display --text "[+] 操作系统和数据库系统特权用户的权限分离"
CheckCorrect 'pam_wheel.so use_uid' 'auth required pam_wheel.so use_uid' /etc/pam.d/su
CheckExists "SU_WHEEL_ONLY yes" /etc/login.defs

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.3.1.审计内容要求"
Display --text "[+] 检查rsyslog配置"
CheckRsyslog 'mail.\*' '-/var/log/mail.log'
CheckRsyslog 'authpriv.\*' '/var/log/auth.log'
CheckRsyslog 'cron.\*' '/var/log/cron.log'

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.3.2.审计内容存储与保护"
CheckRsyslog '\*.\*' "@@*:514"

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.4.1.最小安装原则和补丁更新"
CheckServDown window avahi cups dhcp ldap ftp imap telnet samba nis printer tftp lpd nfs-server nfs-lock ypbind daytime nginx sendmail ntalk ident bootps kshell klogin

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.4.2.禁止root远程登录"
CheckCorrect "PermitRootLogin" "PermitRootLogin yes" /etc/ssh/sshd_config

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.4.3.  启用防火墙"
if [[ $(systemctl is-active firewalld) == 'active' ]];then
    Display --text "Firewalld正在运行" --result "OK" --color GREEN
else
    Display --text "Firewalld未启动" --result "WARNING" --color RED
fi

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.5.1.限制终端登录"
Display --text "hosts.allow:"
Display --text "$(cat /etc/hosts.allow | grep -v '^#')"
Display --text "hosts.deny:"
Display --text "$(cat /etc/hosts.deny | grep -v '^#')"
################################################################################

Display --text "====================================================================="
Display --text "[+] 2.5.2.超时锁定"
CheckExists "TIMEOUT" /etc/profile

################################################################################

Display --text "====================================================================="
Display --text "[+] 2.5.3.系统时间同步"
Display --text "当前ntpserver:"
Display --text "$(grep 'server' /etc/ntp.conf | grep -v '^#' | awk '{print $2}')"
################################################################################

Display --text "====================================================================="
Display --text "[+] 2.5.4.配置企业内部DNS"
Display --text "当前nameserver:"
Display --text "$(grep 'nameserver' /etc/resolv.conf | grep -v "^#" | awk '{print $2}')"

################################################################################

Display --text "====================================================================="
ListUserExtra

################################################################################

Display --text "====================================================================="
Display --text "检查结束，请在$LOGFILE 查看输出结果"
Display --text "以下为修改建议:"
cat $SUGFILE

