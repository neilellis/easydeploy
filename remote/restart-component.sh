#!/bin/bash -x
function joinConsul() {
    while read i
    do
       #If the machine is not available don't hang around, move on quickly
       timelimit -t 2 -T 1 -s 2 consul join $i || :
    done
}

function killTree() {
    gpid=$(pgrep -o $1)
    if [[ ! -z $gpid ]]
    then
        kill -9 $(pstree -p ${gpid} | sed 's/(/\n(/g' | grep '(' | sed 's/(\(.*\)).*/\1/' | tr "\n" " ")
    fi
}

if ! service supervisor status
then
    echo "Supervisor not running, cannot restart component"
    exit 1
fi

touch /tmp/.restart-in-progress
supervisorctl stop $(cat /var/easydeploy/share/.config/component):
docker stop $(docker ps -q)
service docker.io stop
sleep 10
killTree run-docker.sh

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
    echo "Waiting for supervisor processes to restart"
    count=$(( $count + 1 ))
    if (( $count > 30 ))
    then
        echo "Failed to restart component"
        /ezbin/notify.sh ":fire:" "Rebooting, could not restart component $(cat /ezshare/.config/component) due to supervisorctl statuses: $(supervisorctl status)"
       reboot
    else
        sleep 10
    fi
done
rm /tmp/.restart-in-progress
exit 0
