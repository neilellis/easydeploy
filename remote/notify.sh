#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

if [ -f /home/easydeploy/usr/bin/notify.sh ]
then
     /home/easydeploy/usr/bin/notify.sh "$@"
else
     serf event notification "$@"
fi
