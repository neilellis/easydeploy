#!/bin/bash -x
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

cd /home/easydeploy/deployment
export EASYDEPLOY_HOST_IP=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

. ./ed.sh

while true
do
    su  easydeploy -c "git fetch &> .build_log.txt"
    if [ -s .build_log.txt ] && [ ! -f /tmp/.install-in-progress ]
    then
       su easydeploy -c "rm Dockerfile; git pull"
       if su easydeploy -c "/home/easydeploy/bin/build.sh 2>&1 | tee /tmp/build.out"
       then
           /home/easydeploy/bin/restart-component.sh && echo "Component restarted"
       else
            /home/easydeploy/bin/notify.sh ":thumbsdown:" "Build of $(cat /var/easydeploy/share/.config/component) failed: $(cat /tmp/build.out | tail -10)"
            echo "Docker build failed, no redeploy attempted."
       fi
    else
        sleep 120
    fi
    [ -e .build_log.txt ] && rm .build_log.txt
done