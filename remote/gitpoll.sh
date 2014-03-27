#!/bin/bash -x
cd /home/easydeploy/deployment
export EASYDEPLOY_HOST_IP=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

. ./ed.sh
if [ "$EASYDEPLOY_STATE" != "stateless" ]
then
    echo "Stateful app so not polling for project changes."
    sleep 3600
    exit 0
fi

while true
do
    git fetch > build_log.txt 2>&1
    if [ -s build_log.txt ]
    then
       git pull
       if /home/easydeploy/bin/build.sh
       then
            docker kill --signal="SIGINT" $(docker ps -q) || true
            echo "Docker instances sent a Ctrl-C, to politely ask them to stop"
       else
            echo "Docker build failed, no redeploy attempted."
       fi
    else
        sleep 120
    fi
    rm build_log.txt
done