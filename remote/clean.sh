#!/bin/bash
#docker rm $(docker ps -a -q)


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

docker rmi $(docker images -a | grep "^<none>" | awk '{print $3}')

if [ -f /home/easydeploy/deployment/clean.sh ]
then
     /home/easydeploy/deployment/clean.sh
fi

if [ -f /home/easydeploy/usr/bin/clean.sh ]
then
     /home/easydeploy/usr/bin/clean.sh
fi

