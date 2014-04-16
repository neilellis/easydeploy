#!/bin/bash
if [ -f /home/easydeploy/usr/bin/notify.sh ]
then
     /home/easydeploy/usr/bin/notify.sh "$@"
else
     serf event notification "$@"
fi
