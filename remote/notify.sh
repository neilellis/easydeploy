#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin
ip=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
emoji=$1
shift
if [ -f /home/easydeploy/usr/bin/notify.sh ]
then
     /home/easydeploy/usr/bin/notify.sh "$(cat /var/easydeploy/share/.config/hostname)@${ip}" "$emoji" "$*"
else
     serf event notification "$@"
fi
