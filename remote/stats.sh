#!/bin/bash -eu
DEPLOY_ENV=$(cat /var/easydeploy/share/.config/deploy_env)
PROJECT=$(cat /var/easydeploy/share/.config/project)
COMPONENT=$(cat /var/easydeploy/share/.config/component)
IP=$(cat /var/easydeploy/share/.config/ip)
if [[ -f /home/easydeploy/usr/etc/stathat-user.txt ]]
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

function reportMemory() {
    memtotal=`free -m | grep 'Mem' | tr -s ' ' | cut -d ' ' -f 2`
    memfree=`free -m | grep 'buffers/cache' | tr -s ' ' | cut -d ' ' -f 4`
    let "memused=memtotal-memfree"
    let "memusedper=100-memfree*100/memtotal"
    sendVal "memtotal" memtotal
    sendVal "memfree" memfree
    sendVal "memused" $memused
    sendVal "memusedper" memusedper
}

function report() {
    reportLoad
    reportMemory
}

while :
do
    report
    sleep 60
done