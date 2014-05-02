#!/bin/bash -x
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin
if service supervisor status
then
    echo "Supervisord running fine"
else
    if service supervisor restart
    then
        echo "Restarted supervisord"
    else
        echo "Failed to restart supervisord"
        /home/easydeploy/bin/notify.sh "Failed to restart supervisord"
    fi
fi

