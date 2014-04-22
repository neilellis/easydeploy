#!/bin/bash -x
cd /home/easydeploy/deployment
export EASYDEPLOY_HOST_IP=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

. ./ed.sh

while true
do
    su  easydeploy -c "git fetch > .build_log.txt 2>&1"
    if [ -s .build_log ]
    then
       su easydeploy -c "git pull"
       if su easydeploy -c "/home/easydeploy/bin/build.sh > /tmp/build.out"
       then
           supervisorctl restart $(cat /var/easydeploy/share/.config/component):              echo "Component restarted"
       else
            /home/easydeploy/bin/notify.sh "Build of $(cat /var/easydeploy/share/.config/component) failed on ${EASYDEPLOY_HOST_IP} " < tmp/build.out
            echo "Docker build failed, no redeploy attempted."
       fi
    else
        sleep 120
    fi
    [ -e .build_log ] && rm .build_log
done