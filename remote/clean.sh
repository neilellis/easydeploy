#!/bin/bash
docker rm $(docker ps -a -q)
docker rmi $(docker images -a | grep "^<none>" | awk '{print $3}')

if [ -f /home/easydeploy/deployment/clean.sh ]
then
     /home/easydeploy/deployment/clean.sh
fi

if [ -f /home/easydeploy/usr/bin/clean.sh ]
then
     /home/easydeploy/usr/bin/clean.sh
fi

