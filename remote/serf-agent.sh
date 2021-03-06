#!/bin/bash
#This starts the serf agent and forces it to bind to the public IP address
#this behaviour may change in the future, but for now it makes life easier
. /home/easydeploy/bin/env.sh

killall serf || :

if [ "$COMPONENT" == "lb" ]
then
    export COMPONENT="$(cat /var/easydeploy/share/.config/target)-lb"
fi
[ -d /var/serf ] || mkdir /var/serf

#Assign a node name, bind to the public ip, add relevant tags and the event handlers.
/usr/local/bin/serf agent -snapshot /var/serf/snapshot -encrypt $(cat /var/easydeploy/share/.config/serf_key) -node $(cat /var/easydeploy/share/.config/hostname)-${EASYDEPLOY_HOST_IP} -bind ${EASYDEPLOY_HOST_IP} -tag deploy_env=${DEPLOY_ENV} -tag project=${PROJECT} -tag component=${COMPONENT} -event-handler /etc/serf/event-handler.sh  -event-handler  member-join,member-leave,member-failed,member-update,member-reap=/etc/serf/handlers/membership-handler.sh || (sleep 20 && exit -1)