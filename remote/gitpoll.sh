#!/bin/sh
cd /home/easydeploy/deployment
. ./ed.sh
while true
do
    git fetch > build_log.txt 2>&1
    if [ -s build_log.txt ]
    then
       git pull
       if docker build --no-cache=true -t ${COMPONENT} .
       then
            docker kill --signal="SIGINT" $(docker ps -q)
       else
            echo "Docker build failed, no redeploy attempted."
       fi
    else
        sleep 120
    fi
    rm build_log.txt
done