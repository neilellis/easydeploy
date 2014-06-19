#!/bin/bash

function section() {
    echo
    echo "$1"
    echo "$1" | sed s/./=/g
    echo
    $2

}

function postmortem() {
    section "Uptime"  "uptime"
    section "Disks"  "df -h"
    section "Disk Usage"  "du -sh /*"
    section "Netstat" "netstat -tulpn"
    section "Processes" "ps aux"
    section "Process Tree" "pstree"
    section "Docker Processes" "docker ps"
    section "Services" "service --status-all"
    section "Supervisord" "supervisorctl status"
    section "Network Interfaces"  "ifconfig -a"
    section "Uname"  "uname -a"
    section "Memory"  "cat /proc/meminfo"
    section "CPU"  "cat /proc/cpuinfo"
    section "Limits"  "ulimit -a"
    section "Who"  "who"
    section "W"  "w"
#    section "Top Network Bandwidth" "sysdig -n 10 -c topprocs_net"
#    section "Top Disk Access" "sysdig -n 10 -c topprocs_file"
#    section "Top Files Open Processes" "sysdig -n 10  -c fdcount_by proc.name 'fd.type=file'"
}


ip=$(</var/easydeploy/share/.config/ip)

dir=postmortem-$(cat /var/easydeploy/share/.config/hostname)-${ip}-$(date +%s)
cd /eztmp/monthly
mkdir -p $dir
cp /ezlog/* ${dir}
postmortem > ${dir}/postmortem.log
cp /var/log/syslog ${dir}
cp /var/log/upstart/docker.io.log  ${dir}
cp /var/log/supervisor/supervisord.log ${dir}
tar -zcvf /tmp/postmortem.tgz ${dir}

if [ -f /ezubin/send-file.sh ]
then
    /ezubin/send-file.sh /tmp/postmortem.tgz $(cat /var/easydeploy/share/.config/hostname)-${ip}-$(date "+%Y-%m-%d-%H-%M").tgz
fi

cd -
