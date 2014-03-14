#!/bin/bash
set -eux
if [ $# -eq 0 ]
then
    duration=0
else
    duration=$1
fi
echo "Sleeping for $duration to stagger updates"
sleep $duration
echo "Disabling supervisor and killing run.sh"
sudo touch /tmp/easydeploy-run-disable
sudo service supervisor stop
sudo killall run.sh
docker rm $(docker -q -a)
sudo su - easydeploy <<EOF
cd /home/easydeploy/config
git pull
docker build -t $(cat /home/easydeploy/.install-type) .
EOF
. /home/easydeploy/config/ed.sh
sudo envsubst < /home/easydeploy/template/template-run.conf  > /etc/supervisor/conf.d/run.conf
echo "Rebooting"
sudo shutdown -r +2
sleep 118
sudo rm /tmp/easydeploy-run-disable
