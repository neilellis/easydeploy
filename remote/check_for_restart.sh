#!/bin/bash

if [ -f /home/easydeploy/deployment/health_check.sh ]
then
    if ! timelimit -t30 -T10 bash /home/easydeploy/deployment/health_check.sh
    then
        supervisorctl restart $(cat /var/easydeploy/share/.config/component):
        /home/easydeploy/bin/notify.sh "Restarted $(cat /var/easydeploy/share/.config/component) due to health check failure."
    fi
fi
