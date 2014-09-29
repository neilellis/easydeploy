#!/bin/bash
docker rm $(docker ps -a -q)


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

if [[ $EASYDEPLOY_STATE == "stateless" ]]  && (( $(df -h / | tail -1 | tr -s ' ' | cut -d' ' -f5 | tr -d '%') > 50 ))
then
    docker rmi $(docker images -a | grep "<none>" | awk '{print $3}') || :
fi

if (( $(df -h / | tail -1 | tr -s ' ' | cut -d' ' -f5 | tr -d '%') > 50 ))
then
    echo "FAIL: Root disk usage at $(df -h / | tail -1 | tr -s ' ' | cut -d' ' -f5)"
fi

if [ -f /home/easydeploy/project/ezd/bin/clean.sh ]
then
     /home/easydeploy/project/ezd/bin/clean.sh
fi

exit 0

