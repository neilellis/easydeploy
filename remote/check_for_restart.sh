#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

if [  -f /tmp/.install-in-progress ]
then
    echo "Install in progress."
    exit 0
fi

function joinConsul() {
    while read i
    do
       #If the machine is not available don't hang around, move on quickly
       timelimit -t 2 -T 1 -s 2 consul join $i || :
    done
}


/home/easydeploy/bin/supervisord_monitor.sh


if [ -f /home/easydeploy/deployment/health_check.sh ]
then
    timelimit -t300 -T10 bash /home/easydeploy/deployment/health_check.sh > /tmp/.health_check_restart_tmp_value.txt
    result=$?
    if (( $result == 1 ))
    then
        /ezbin/postmortem.sh
        sleep $[ ( $RANDOM % 180 )  + 1 ]s
        date
        /ezbin/restart-component.sh
        sleep 30
        /ezbin/notify.sh ":recycle:" "Restarted component $(cat /ezshare/.config/component) due to health check failure: $(cat /tmp/.health_check_restart_tmp_value.txt)"
        if ! timelimit -t300 -T10 bash /home/easydeploy/deployment/health_check.sh > /tmp/.health_check_restart_tmp_value.txt
        then
            /ezbin/notify.sh ":skull:" "Rebooting server due to health check failure: $(cat /tmp/.health_check_restart_tmp_value.txt)"
            echo "Rebooting ..."
            reboot
        fi
    elif (( $result == 3 ))
    then
       /ezbin/notify.sh ":electric_plug:" "Service depedency failed for component $(cat /ezshare/.config/component): $(cat /tmp/.health_check_restart_tmp_value.txt)"
    fi
fi
