#!/bin/bash

[[ $( id -u ) != 0 ]] && {
    echo  -e "\033[32mThis Script Should Be Run by User \033[33mRoot\033[0m\033[0m" 2>&1
    exit 1
}

# CPU Info
echo  -e "\033[32m
CPU Info >>>
    Model:\t $(grep 'model name' /proc/cpuinfo | awk -F: '{print $2}')
    Frequency:\t $(grep 'cpu MHz' /proc/cpuinfo | awk -F: '{print $2}')MHz
    Cache:\t $(grep 'cache size' /proc/cpuinfo | awk -F: '{print $2}')
    Process Count: $(grep -c processor /proc/cpuinfo)
\033[0m"

# Mem Info
echo  -e "\033[32m
Mem Info >>>
    Total:\t $(free -h | head -n2 | tail -n1 | awk '{print $2}')
    Used:\t $(free -h | head -n2 | tail -n1 | awk '{print $3}')
\033[0m"

# Disk Info
echo  -e "\033[32m
Disk Info >>>
    $(df -h | grep -E '^/dev/' |
    awk '{ print $1"\n\tTotal:\t"$2"\n\tUsed:\t"$3"\n\tAvail:\t"$4"\n\tUsed%:\t"$5"\n\tMount:\t"$6"\n"}')
\033[0m"

# System Info
echo  -e "\033[32m
System Info >>>
    System:\t$(sed -n '/^PRETTY/p' /etc/os-release | awk -F'"' '{print $2}')
    Kernel:\t$(uname -r)
\033[0m"
