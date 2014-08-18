#!/bin/bash
#This starts the serf agent and forces it to bind to the public IP address
#this behaviour may change in the future, but for now it makes life easier
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

killall consul || :

. /home/easydeploy/project/ezd/etc/ezd.sh

export EASYDEPLOY_HOST_IP=$(</var/easydeploy/share/.config/ip)
export PROJECT=$(cat /var/easydeploy/share/.config/project)
export COMPONENT=$(cat /var/easydeploy/share/.config/component)
export DEPLOY_ENV=$(cat /var/easydeploy/share/.config/deploy_env)
[ -d /var/consul ] || mkdir /var/consul

client_flag=-client=127.0.0.1
if [ ! -z "$EASYDEPLOY_PRIMARY_ADMIN_SERVER" ]
then
    client_flag=-client=${EASYDEPLOY_HOST_IP}
fi

#Assign a node name, bind to the public ip, add relevant tags and the event handlers.
/usr/local/bin/consul agent $1 -server -ui-dir  /usr/local/consul_ui  -config-dir=/etc/consul.d -node=$(cat /var/easydeploy/share/.config/hostname)-$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'| tr '.' '-') -bind=${EASYDEPLOY_HOST_IP} ${client_flag} || (sleep 20 && exit -1)