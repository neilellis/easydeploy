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
killall run.sh  || echo "no run.sh killed"
sudo su - easydeploy <<EOF
cd /home/easydeploy/config
git pull
docker build -t $(cat /home/easydeploy/.install-type) .
EOF
. /home/easydeploy/config/ed.sh

if [[ ${EASYDEPLOY_STATE} == "stateless" ]]
then
     [ $(docker ps -q -a|wc -l) -gt 0 ]  && docker rm $(docker ps -q -a)
fi

 envsubst < /home/easydeploy/template/template-run.conf  > /etc/supervisor/conf.d/run.conf
echo "Rebooting"
shutdown -r +2
sleep 118
rm /tmp/easydeploy-run-disable
