#!/bin/bash
. /home/easydeploy/bin/env.sh

ip=$(</var/easydeploy/share/.config/ip)
emoji=$1
shift
if [ -f /home/easydeploy/usr/bin/notify.sh ]
then
     /home/easydeploy/usr/bin/notify.sh "$(cat /var/easydeploy/share/.config/hostname)@${ip}" "$emoji" "$*"
else
     serf event notification "$@"
fi
