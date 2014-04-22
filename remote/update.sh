#!/bin/bash
set -x
if [ $# -eq 0 ]
then
    duration=0s
else
    duration=$1
fi
echo "Sleeping for $duration to stagger updates"
sleep $duration
echo "Disabling supervisor and killing run.sh"
touch /tmp/easydeploy-run-disable
touch /var/easydeploy/share/.config/easydeploy-run-disable
service supervisor stop
killall run.sh  || echo "No run.sh killed"
export EASYDEPLOY_HOST_IP=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
. /home/easydeploy/deployment/ed.sh
sudo su - easydeploy -c "/home/easydeploy/bin/build.sh"


[ $(docker ps -q -a|wc -l) -gt 0 ] && docker stop $(docker ps -q) && docker rm $(docker ps -q -a)
docker images -a|grep '^<none>'|tr -s ' '|cut -d' ' -f 3|xargs docker rmi  || :

sudo apt-get update
sudo unattended-upgrades
#sudo apt-get -y upgrade
echo "Rebooting"
shutdown -r +2
sleep 118
rm /var/easydeploy/share/.config/easydeploy-run-disable
rm /tmp/easydeploy-run-disable

