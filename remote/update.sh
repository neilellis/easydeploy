#!/bin/bash
. /home/easydeploy/bin/env.sh

if [ -f /tmp/.install-in-progress ]
then
    echo "Install in progress, cancelling update."
    exit 0
fi
set -x
if [ $# -eq 0 ]
then
    duration=0s
else
    duration=$1
fi
echo "Sleeping for $duration to stagger updates"
sleep $duration
echo "Disabling supervisor and killing run-docker.sh"
touch /tmp/easydeploy-run-disable
touch /var/easydeploy/share/.config/easydeploy-run-disable
sudo apt-get -q update
sudo unattended-upgrades
#sudo apt-get -y upgrade
echo "Rebooting"
shutdown -r +2
sleep 118
rm /var/easydeploy/share/.config/easydeploy-run-disable
rm /tmp/easydeploy-run-disable

