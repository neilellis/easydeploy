#!/bin/bash -x

. /home/easydeploy/bin/env.sh


if ! service supervisor status
then
    echo "Supervisor not running, cannot restart component"
    exit 1
fi

touch /tmp/.restart-in-progress
/ezbin/lb_off.sh
sleep $1
supervisorctl restart ${COMPONENT}:
sleep $1
/ezbin/lb_on.sh
rm /tmp/.restart-in-progress
exit 0
