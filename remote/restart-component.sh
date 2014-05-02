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
service docker stop
killall docker
supervisorctl stop consul
rm -rf /var/consul/*
supervisorctl start consul
sleep 30
cat /var/easydeploy/share/.config/discovery/all.txt | joinConsul
sleep 30
service docker start
supervisorctl start $(cat /var/easydeploy/share/.config/component):
