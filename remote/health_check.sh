#!/bin/bash
if [ -f /home/easydeploy/deployment/health_check.sh ]
then
    if sudo su - easydeploy -c "timelimit -t10 -T5 bash /home/easydeploy/deployment/health_check.sh"
    then
        echo "OK"
    fi
else
  echo "OK"
fi


