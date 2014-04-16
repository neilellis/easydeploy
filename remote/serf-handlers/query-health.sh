#!/bin/bash -u
if supervisorctl status | grep FATAL &> /dev/null
then
    echo "FAIL: Supervisord processes are not working."
    exit 0
fi

if ! service docker status | grep running &> /dev/null
then
    echo  "FAIL: Docker process not running."
    exit 0
fi

if ! service btsync status | grep running &> /dev/null
then
    echo  "FAIL: Bit Torrent Sync process not running."
    exit 0
fi

if (( $(df -h / | tail -1 | tr -s ' ' | cut -d' ' -f5 | tr -d '%') > 90 ))
then
    echo "FAIL: Root disk usage at $(df -h / | tail -1 | tr -s ' ' | cut -d' ' -f5)"
    exit 0
fi

if [ -f /home/easydeploy/deployment/health_check.sh ]
then
    if sudo su - easydeploy -c "timelimit -t10 -T5 bash /home/easydeploy/deployment/health_check.sh"
    then
        echo "OK"
    fi
else
  echo "OK"
fi
exit 0
