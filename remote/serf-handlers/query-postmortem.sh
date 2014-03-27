#!/bin/sh

function section() {
    echo "$1"
    echo "$1" | sed s/./=/g
    echo
    $2

}
section "Uname"  "uname -a"
section "Network Interfaces"  "ifconfig -a"
section "Memory"  "cat /proc/meminfo"
section "CPU"  "cat /proc/cpuinfo"
section "Disks"  "df -h"
section "Limits"  "ulimit -a"
section "Services" "service --status-all"
section "Processes" "ps aux"
section "Netstat" "netstat -tulpn"
section "Who"  "who"
section "W"  "w"
section "Uptime"  "uptime"
section "Disk Usage"  "du -sh /*"
