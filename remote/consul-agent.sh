#!/bin/bash
#This starts the serf agent and forces it to bind to the public IP address
#this behaviour may change in the future, but for now it makes life easier

export EASYDEPLOY_HOST_IP=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
export PROJECT=$(cat /var/easydeploy/share/.config/project)
export COMPONENT=$(cat /var/easydeploy/share/.config/component)
export DEPLOY_ENV=$(cat /var/easydeploy/share/.config/deploy_env)
[ -d /var/consul ] || mkdir /var/consul
#Assign a node name, bind to the public ip, add relevant tags and the event handlers.
/usr/local/bin/consul agent $1 -server -config-dir=/etc/consul.d -node=${DEPLOY_ENV}-${PROJECT}-${COMPONENT}-$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'| tr '.' '-') -bind=${EASYDEPLOY_HOST_IP} || (sleep 20 && exit -1)