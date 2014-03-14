#!/bin/bash
set -eux
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
service supervisor stop
killall run.sh
docker rm $(docker -q -a)
sudo su - easydeploy <<EOF
cd /home/easydeploy/config
git pull
docker build -t $(cat /home/easydeploy/.install-type) .
EOF
. /home/easydeploy/config/ed.sh
 envsubst < /home/easydeploy/template/template-run.conf  > /etc/supervisor/conf.d/run.conf
echo "Rebooting"
shutdown -r +2
sleep 118
rm /tmp/easydeploy-run-disable
