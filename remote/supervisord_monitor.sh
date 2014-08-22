#!/bin/bash -x

. /home/easydeploy/bin/env.sh

if [  -f /tmp/.started ]
then
    echo "Server hasn't finished starting up yet"
    exit 0
fi


if [  -f /tmp/.install-in-progress ]
then
    echo "Install in progress."
    exit 0
fi

if [ -f /tmp/.initializing-in-progress ]
then
    echo "Still initialzing component"
    exit 0
fi

if test $(find "/tmp/.restart-in-progress" -mmin -30)
then
    echo "Restart in progress"
    exit 0
fi


IP=$(</var/easydeploy/share/.config/ip)

function send_log() {
    [ -f /ezubin/send-file.sh ] && /ezubin/send-file.sh /var/log/supervisor/supervisord.log  supervisord-$(cat /var/easydeploy/share/.config/hostname)-${IP}.log
}

function restart_sd() {

    send_log
    service supervisor restart
    sleep 90
    if service supervisor status | grep running &> /dev/null
    then
        echo "Restarted supervisord"
        /home/easydeploy/bin/notify.sh ":recycle:" "Restarted supervisord"
    else
        echo "FAIL: Failed to restart supervisord"
        /home/easydeploy/bin/notify.sh ":fire:" "Failed to restart supervisord, will reboot"
        send_log
        reboot
        exit 0
    fi
}


function serf_check() {
    serf members || serf members -rpc-addr=${IP}:8400
}



if [ ! -S /var/run/supervisor.sock ]
then
    echo  "FAIL: Supervisord socket not present."
        /home/easydeploy/bin/notify.sh ":ghost:" "Supervisord was dead, no socket"
        restart_sd
        exit 0
fi




if service supervisor status | grep "running" &> /dev/null
then
    echo "Supervisord running fine"
    if supervisorctl status | grep FATAL &> /dev/null
    then
        echo "Supervisord running but FATAL statuses found."
        /home/easydeploy/bin/notify.sh ":ghost:" "FATALs found $(supervisorctl status)"
        restart_sd
        exit 0
    fi
else
    restart_sd
    exit 0
fi


if ! serf_check &> /dev/null
then
    echo  "FAIL: Serf process not working."
    /home/easydeploy/bin/notify.sh ":ghost:" "Serf is dead"
    supervisorctl restart serf
    sleep 60
    serf_check || restart_sd
    serf_check || ( /home/easydeploy/bin/notify.sh ":fire:" "Failed to restart serf, will reboot" && reboot )
    exit 0
fi


if  service docker status | grep running &> /dev/null
then
    :
else
    echo  "FAIL: Docker process not running."
    /home/easydeploy/bin/notify.sh ":ghost:" "Docker is dead"
    [ -f /var/log/upstart/docker.log ] && [ -f /ezubin/send-file.sh ] && /ezubin/send-file.sh /var/log/upstart/docker.log  docker-$(cat /var/easydeploy/share/.config/hostname)-${IP}.log
    service docker restart
    sleep 120
    ( service docker status | grep running &> /dev/null ) || ( /home/easydeploy/bin/notify.sh ":fire:" "Failed to restart docker, will reboot" && reboot )
    exit 0

fi
