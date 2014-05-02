#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

if [ -f /home/easydeploy/deployment/health_check.sh ]
then
    if sudo su - easydeploy -c "timelimit -t300 -T5 bash /home/easydeploy/deployment/health_check.sh"
    then
        echo "OK"
    fi
else
  echo "OK"
fi


