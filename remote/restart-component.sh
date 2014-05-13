#!/bin/bash -x
function joinConsul() {
    while read i
    do
       #If the machine is not available don't hang around, move on quickly
       timelimit -t 2 -T 1 -s 2 consul join $i || :
    done
}

supervisorctl stop $(cat /var/easydeploy/share/.config/component):
docker stop $(docker ps -q)
service docker.io stop
killall docker
supervisorctl stop consul
rm -rf /var/consul/*
supervisorctl start consul
sleep 30
cat /var/easydeploy/share/.config/discovery/all.txt | joinConsul
sleep 30
service docker.io start
supervisorctl start $(cat /var/easydeploy/share/.config/component):

count=0
while supervisorctl status | grep -v "Running"
do
    echo "Waiting for supervisor to restart"
    count=$(( $count + 1 ))
    if (( $count > 30 ))
    then
        exit 1
    else
        sleep 10
    fi
done
exit 0
