#!/bin/bash -eu
DEPLOY_ENV=$(cat /var/easydeploy/share/.config/deploy_env)
PROJECT=$(cat /var/easydeploy/share/.config/project)
COMPONENT=$(cat /var/easydeploy/share/.config/component)
IP=$(cat /var/easydeploy/share/.config/ip)
if [[ -f /home/easy${memtotal}r/etc/stathat-user.txt ]]
then
    STATHAT=$(cat /home/easydeploy/usr/etc/stathat-user.txt)
else
    STATHAT=
fi

function sendVal() {
    [[ -z $STATHAT ]] || curl -d "stat=${1} ${PROJECT} ${DEPLOY_ENV} ${COMPONENT} ${IP}&email=${STATHAT}&value=${2}" http://api.stathat.com/ez
}

function sendCount() {
    [[ -z $STATHAT ]] || curl -d "stat=${1} ${PROJECT} ${DEPLOY_ENV} ${COMPONENT} ${IP}&email=${STATHAT}&value=${2}" http://api.stathat.com/ez
}


function reportLoad() {
    sendVal "load"  `uptime | awk '{ print $10}' | cut -f1 -d,`
}

function reportDiskUsage() {
    usage=$(df -m / | tail -1 | awk '{$1=$1}1' OFS=',' | cut -d, -f 5 | tr -d '%')
    sendVal "disk_usage_slash" ${usage}
}

function reportMemory() {
    memtotal=`free -m | grep 'Mem' | tr -s ' ' | cut -d ' ' -f 2`
    memfree=`free -m | grep 'buffers/cache' | tr -s ' ' | cut -d ' ' -f 4`
    let "memused=memtotal-memfree"
    let "memusedper=100-memfree*100/memtotal"
    sendVal "memtotal" $memtotal
    sendVal "memfree" ${memfree}
    sendVal "memused" ${memused}
    sendVal "memusedper" ${memusedper}
}

function reportProcesses() {
    procs=$(ps aux | wc -l)
    sendVal "procs" ${procs}
}

function reportDstat() {
    csvLine=$(tail -1 < /tmp/dstat.csv)
    echo csvLine | IFS=, read cpu_usr cpu_sys cpu_idl cpu_wait hiq siq disk_read disk_write net_recv net_send page_in page_out sysint syscsw
    sendVal "cpu_usr" ${cpu_usr}
    sendVal "cpu_sys" ${cpu_sys}
    sendVal "cpu_idl" ${cpu_idl}
    sendVal "cpu_wait" ${cpu_wait}
    sendVal "disk_read" ${disk_write}
    sendVal "net_recv" ${net_send}
    sendVal "page_in" ${page_out}
}
function report() {
    reportLoad
    reportMemory
    reportDiskUsage
    reportProcesses
    reportDstat
}

while :
do
    dstat --output /tmp/dstat.csv 60 1
    report
done