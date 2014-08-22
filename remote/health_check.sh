#!/bin/bash


. /home/easydeploy/bin/env.sh

if supervisorctl status | grep FATAL &> /dev/null
then
    echo "FAIL: Supervisord processes are not working."
    exit 1
fi


if ! service docker status | grep running &> /dev/null
then
    echo  "FAIL: Docker process not running."
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


rootUsage=$(df -h / | tail -1 | tr -s ' ' | cut -d' ' -f5 | tr -d '%')
if (( $rootUsage > 80 ))
then
    /home/easydeploy/bin/clean.sh
fi

rootUsage=$(df -h / | tail -1 | tr -s ' ' | cut -d' ' -f5 | tr -d '%')
if (( $rootUsage > 90 ))
then
    echo "FAIL: Root disk usage at $rootUsage"
    exit 1
fi


if [ -f /home/easydeploy/project/ezd/bin/health_check.sh ]
then
    if sudo su - easydeploy -c "timelimit -t300 -T5 bash /home/easydeploy/project/ezd/bin/health_check.sh"
    then
        echo "OK"
        exit 0
    else
        exit 1
    fi
else
  echo "OK"
  exit 0
fi


