#!/bin/bash -x
if service supervisord status
then
    echo "Supervisord running fine"
else
    if service supervisord restart
    then
        echo "Restarted supervisord"
    else
        echo "Failed to restart supervisord"
        /home/easydeploy/bin/notify.sh "Failed to restart supervisord"
    fi
fi

