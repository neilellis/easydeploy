#!/bin/bash  -x
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

. /home/easydeploy/bin/env.sh

if [  -f /tmp/.install-in-progress ]
then
    echo "Install in progress"
    exit 0
fi

if [ -f /tmp/.initializing-in-progress ]
then
    echo "Still initializing component"
    exit 0
fi


if test $(find "/tmp/.restart-in-progress" -mmin -30)
then
    echo "Cannot restart component, restart already in progress"
    exit 0
fi



/home/easydeploy/bin/supervisord_monitor.sh


if [ -f /home/easydeploy/project/ezd/bin/health_check.sh ]
then
    timelimit -t300 -T10 bash /home/easydeploy/project/ezd/bin/health_check.sh > /tmp/.health_check_restart_tmp_value.txt
    result=$?
    error_text=$(cat /tmp/.health_check_restart_tmp_value.txt | tr '\n' ' ' | tr '"' ' ')
    if (( $result == 1 ))
    then
        serf tags -set health=warning
        cat /tmp/.health_check_restart_tmp_value.txt
        /ezbin/postmortem.sh
        sleep $[ ( $RANDOM % 180 )  + 1 ]s
        date
        /ezbin/restart-component.sh
        sleep 30
        /ezbin/notify.sh ":recycle:" "Restarted component $(cat /ezshare/.config/component) due to health check failure: $error_text"  || :
        if ! timelimit -t300 -T10 bash /home/easydeploy/project/ezd/bin/health_check.sh > /tmp/.health_check_restart_tmp_value.txt
        then
            serf tags -set health=failed
            serf leave
            error_text=$(cat /tmp/.health_check_restart_tmp_value.txt | tr '\n' ' ' | tr '"' ' ')
            cat /tmp/.health_check_restart_tmp_value.txt
            /ezbin/notify.sh ":skull:" "Rebooting server due to health check failure: $error_text" || :
            echo "Rebooting ..."
            reboot
        fi
    elif (( $result == 3 ))
    then
        serf tags -set health=warning
       /ezbin/notify.sh ":electric_plug:" "Service dependency failed for component $(cat /ezshare/.config/component): $error_text" || :
    else
        serf tags -set health=ok
    fi
fi
