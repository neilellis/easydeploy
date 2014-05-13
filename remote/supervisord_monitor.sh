#!/bin/bash -x
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

ip=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

function send_log() {
    [ -f /ezubin/send-file.sh ] && /ezubin/send-file.sh /var/log/supervisor/supervisord.log  supervisord-$(cat /var/easydeploy/share/.config/hostname)-${ip}-$(date "+%Y-%m-%d-%H-%M").log
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

function consul_check() {
    consul members || consul members -rpc-addr=${ip}:8400
}

if ! serf_check
then
    echo  "FAIL: Serf process not working."
    /home/easydeploy/bin/notify.sh ":ghost:" "Serf is dead"
    supervisorctl restart serf
    sleep 60
    serf_check || restart_sd
    serf_check || ( /home/easydeploy/bin/notify.sh ":fire:" "Failed to restart serf, will reboot" && reboot )
fi

if ! consul_check
then
    echo  "FAIL: Consul process not working."
    /home/easydeploy/bin/notify.sh ":ghost:" "Consul is dead"
    supervisorctl restart consul
    sleep 60
    consul_check || restart_sd
    consul_check || ( /home/easydeploy/bin/notify.sh ":fire:" "Failed to restart consul, will reboot" && reboot )
fi


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



