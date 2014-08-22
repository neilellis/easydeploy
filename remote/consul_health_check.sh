#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin


if [ -f /home/easydeploy/project/ezd/bin/health_check.sh ]
then
    if ! sudo su - easydeploy -c "timelimit -t300 -T5 bash /home/easydeploy/project/ezd/bin/health_check.sh &> /tmp/.health.txt"
    then
        cat /tmp/.health.txt | tail -2
        exit 2
    fi
fi


if ! service docker status | grep running &> /dev/null
then
    echo  "FAIL: Docker process not running."
    exit 2
fi


if supervisorctl status | grep FATAL &> /dev/null
then
    echo "FAIL: Supervisord processes are not working."
    exit 1
fi



if ! service btsync status | grep running &> /dev/null
then
    echo  "FAIL: Bit Torrent Sync process not running."
    exit 1
fi

if ! serf members
then
    echo  "FAIL: Serf process not working."
    exit 1
fi

if (( $(df -h / | tail -1 | tr -s ' ' | cut -d' ' -f5 | tr -d '%') > 90 ))
then
    echo "FAIL: Root disk usage at $(df -h / | tail -1 | tr -s ' ' | cut -d' ' -f5)"
    /home/easydeploy/bin/clean.sh
    exit 1
fi

echo "OK"
exit 0


