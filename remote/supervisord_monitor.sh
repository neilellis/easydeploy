#!/bin/bash -x
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

if [ -f /tmp/.initializing-in-progress ]
then
    echo "Still initialzing component"
    exit 0
fi

ip=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

function send_log() {
    [ -f /ezubin/send-file.sh ] && /ezubin/send-file.sh /var/log/supervisor/supervisord.log  supervisord-$(cat /var/easydeploy/share/.config/hostname)-${ip}.log
}

function restart_sd() {

    send_log
    service supervisor restart
    sleep 90
    if service supervisor status | grep running
    then
        echo "Restarted supervisord"
        /home/easydeploy/bin/notify.sh ":recycle:" "Restarted supervisord"
    else
        echo "Failed to restart supervisord"
        /home/easydeploy/bin/notify.sh ":fire:" "Failed to restart supervisord, will reboot"
        send_log
        reboot
    fi
}


function serf_check() {
    serf members || serf members -rpc-addr=${ip}:8400
}



if [ ! -S /var/run/supervisor.sock ]
then
    echo  "FAIL: Supervisord socket not present."
        /home/easydeploy/bin/notify.sh ":ghost:" "Supervisord was dead, no socket"
        restart_sd
fi




if service supervisor status
then
    echo "Supervisord running fine"
    if supervisorctl status | grep FATAL &> /dev/null
    then
        echo "Supervisord running but FATAL statuses found."
        /home/easydeploy/bin/notify.sh ":ghost:" "FATALs found $(supervisorctl status)"
        restart_sd
    fi
else
    restart_sd
fi


if ! serf_check
then
    echo  "FAIL: Serf process not working."
    /home/easydeploy/bin/notify.sh ":ghost:" "Serf is dead"
    supervisorctl restart serf
    sleep 60
    serf_check || restart_sd
    serf_check || ( /home/easydeploy/bin/notify.sh ":fire:" "Failed to restart serf, will reboot" && reboot )
fi


if ! service docker.io status | grep running &> /dev/null
then
    echo  "FAIL: Docker process not running."
    /home/easydeploy/bin/notify.sh ":ghost:" "Docker is dead"
    /var/log/upstart/docker.io.log
    [ -f /ezubin/send-file.sh ] && /ezubin/send-file.sh /var/log/upstart/docker.io.log  docker-$(cat /var/easydeploy/share/.config/hostname)-${ip}.log
    service docker.io restart
    sleep 120
    ( service docker.io status | grep running &> /dev/null ) || ( /home/easydeploy/bin/notify.sh ":fire:" "Failed to restart docker.io, will reboot" && reboot )
fi




