#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

function joinConsul() {
    while read i
    do
       #If the machine is not available don't hang around, move on quickly
       timelimit -t 2 -T 1 -s 2 consul join $i || :
    done
}

if [ -f /home/easydeploy/deployment/health_check.sh ] && [ ! -f /tmp/.install-in-progress ]
then
    if ! timelimit -t30 -T10 bash /home/easydeploy/deployment/health_check.sh
    then
        sleep $[ ( $RANDOM % 180 )  + 1 ]s
        date
        /home/easydeploy/bin/restart-component.sh
        /home/easydeploy/bin/notify.sh "Restarted $(cat /var/easydeploy/share/.config/component) due to health check failure."
    fi
fi
