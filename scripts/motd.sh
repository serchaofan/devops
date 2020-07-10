#!/bin/bash

#Cpu load
load1=`cat /proc/loadavg | awk '{print $1}'`
load5=`cat /proc/loadavg | awk '{print $2}'`
load15=`cat /proc/loadavg | awk '{print $3}'`
  
#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))
up_lastime=`date -d "$(awk -F. '{print $1}' /proc/uptime) second ago" +"%Y-%m-%d %H:%M:%S"`
 
# CPU usage
cpu_all=$(sar -u 1 1 | tail -n1)
cpu_user=$(echo $cpu_all | awk '{print $3}')
cpu_system=$(echo $cpu_all | awk '{print $5}')
cpu_iowait=$(echo $cpu_all | awk '{print $6}')
cpu_idle=$(echo $cpu_all | awk '{print $8}')

#Memory Usage
# mem_usage=`free -m | awk '/Mem:/{total=Extra close brace or missing open brace3} END {printf("%3.2f%%",used/total*100)}'`
swap_usage=`free -m | awk '/Swap/{printf "%.2f%",3/2*100}'`
# mem_total_num=$(free | head -n2 | tail -n1 | awk '{print $2}')
# mem_used_num=$(free | head -n2 | tail -n1 | awk '{print $3}')
# mem_usage=$(awk 'BEGIN{printf "%.2f%\n",($mem_used_num/$mem_total_num)*100}')
mem_total=$(free -h | head -n2 | tail -n1 | awk '{print $2}')
mem_used=$(free -h | head -n2 | tail -n1 | awk '{print $3}')

#Processes
processes=`ps aux | wc -l`
  
#User
users=`users | wc -w`
USER=`whoami`
  
#System fs usage
Filesystem=$(df -h | awk '/^\/dev/{print $6}')


# echo "System Time: `date "+%F %T"`"
# echo "----------------------------------------------"
printf "Kernel Version:\t%s\n" `uname -r`
printf "HostName:\t%s\n" `echo $(hostname)`
echo "----------------------------------------------"
printf "Interface\tIP Address\n"
for i in $(ip -4 ad | grep 'state ' | awk -F":" '!/^[0-9]*: ?lo/ {print $2}')
do
    # MAC=$(ip ad show dev $i | grep "link/ether" | awk '{print $2}')
    IP=$(ip ad show dev $i | awk '/inet / {print $2}')
    printf $i"\t\t$IP\n"
done
echo "----------------------------------------------"
printf "System Load:\t%s %s %s\n" $load1, $load5, $load15
printf "System Uptime:\t%s "days" %s "hours" %s "min" %s "sec"\n" $upDays $upHours $upMins $upSecs
printf "CPU Usage: \n\tuser:\t%s\n\tsystem:\t%s\n\tiowait:\t%s\n\tidle:\t%s\n" $cpu_user $cpu_system $cpu_iowait $cpu_idle
echo "----------------------------------------------"
printf "Memory Total:\t%s\t\tMemory Used:\t%s\n" $mem_total $mem_used
printf "Memory Usage:\t%s\t\t\tSwap Usage:\t%s\n" $mem_usage $swap_usage
echo "----------------------------------------------"
printf "Login Users:\t%s\nUser:\t\t%s\n" $users $USER
printf "Processes:\t%s\n" $processes
echo "----------------------------------------------"
printf "Filesystem\tUsage\n"
for f in $Filesystem
do
    Usage=$(df -h | awk '{if($NF=="'''$f'''") print $5}')
    echo -e "$f\t\t$Usage"
done
printf "\n"
echo "----------------------------------------------"