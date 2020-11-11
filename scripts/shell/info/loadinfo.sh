#!/bin/bash

#Cpu load#############################################
cpuload=$(uptime=$(uptime); echo ${uptime##*:})

# CPU usage ###########################################
cpu_all=$(sar -u 1 1 | tail -1)
cpu_user=$(echo $cpu_all | awk '{print $3}')
cpu_system=$(echo $cpu_all | awk '{print $5}')
cpu_iowait=$(echo $cpu_all | awk '{print $6}')
cpu_idle=$(echo $cpu_all | awk '{print $8}')

#Memory Usage############################################
mem_total=$(free | sed -n '2p' | awk '{print $2}')
mem_used=$(free | sed -n '2p' | awk '{print $3}')
mem_avai=$(free | sed -n '2p' | awk '{print $7}')
ph_mem_usage=$(awk -v mem_used=$mem_used -v mem_total=$mem_total 'BEGIN{ printf "%.2f%",(mem_used/mem_total)*100 }')
lo_mem_usage=$(awk -v mem_avai=$mem_avai -v mem_total=$mem_total 'BEGIN{ printf "%.2f%",(mem_avai/mem_total)*100 }')

#Processes############################################
processes=`ps aux | wc -l`

#User#############################################
users=`users | wc -w`
USER=`whoami`

#System fs usage########################################
Filesystem=$(df -h | awk '/^\/dev/{print $6}')


# echo "System Time: `date "+%F %T"`"
echo "======================================================="
printf "Kernel Version:\t%s\n" `uname -r`
printf "HostName:\t%s\n" `echo $(hostname)`
echo "======================================================="
printf "Interface\tIP Address\n"
for i in $(ip -4 ad | grep 'state ' | awk -F":" '!/^[0-9]*: ?lo/ {print $2}')
do
    # MAC=$(ip ad show dev $i | grep "link/ether" | awk '{print $2}')
    IP=$(ip ad show dev $i | awk '/inet / {print $2}')
    printf $i"\t\t$IP\n"
done
echo "======================================================="
echo -e "System Load:\t$cpuload"
printf "System Uptime:\t%s days\n" $(uptime | awk '{print $3}')
printf "CPU Usage: \n\tuser:\t%s\n\tsystem:\t%s\n\tiowait:\t%s\n\tidle:\t%s\n" $cpu_user $cpu_system $cpu_iowait $cpu_idle
echo "======================================================="
printf "Memory Total:\t%s\t\tMemory Used:\t%s\n" $(free -h | sed -n '2p' | awk '{print $2}') $(free -h | sed -n '2p' | awk '{print $3}')
printf "Memory Usage (Physical):\t%s\n" $ph_mem_usage
printf "Memory Usage (Logical): \t%s\n" $lo_mem_usage
echo "======================================================="
printf "Login Users:\t%s\nUser:\t\t%s\n" $users $USER
printf "Processes:\t%s\n" $processes
echo "======================================================="
printf "Filesystem\tUsage\n"
for f in $Filesystem
do
    Usage=$(df -h | awk '{if($NF=="'''$f'''") print $5}')
    echo -e "$f\t\t$Usage"
done
printf "\n"
echo "======================================================="
