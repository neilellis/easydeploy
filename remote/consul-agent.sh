#!/bin/bash
#This starts the consul agent and forces it to bind to the public IP address
#this behaviour may change in the future, but for now it makes life easier
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

killall consul || :

. /home/easydeploy/project/ezd/etc/ezd.sh

export EASYDEPLOY_HOST_IP=$(</var/easydeploy/share/.config/ip)
export PROJECT=$(cat /var/easydeploy/share/.config/project)
export COMPONENT=$(cat /var/easydeploy/share/.config/component)
export DEPLOY_ENV=$(cat /var/easydeploy/share/.config/deploy_env)
export MACHINE_NAME=$(</var/easydeploy/share/.config/hostname)
[ -d /var/consul ] || mkdir /var/consul

client_flag=-client=127.0.0.1

#Assign a node name, bind to the public ip, add relevant tags and the event handlers.
[ -d /var/easydeploy/.consul_state ] || mkdir -p /var/easydeploy/.consul_state
/usr/local/bin/consul agent -bootstrap-expect 3 -server -ui-dir  /usr/local/consul_ui  -config-dir=/etc/consul.d
 -data-dir=/var/easydeploy/.consul_state -node=${MACHINE_NAME}-${EASYDEPLOY_HOST_IP}  -advertise=${EASYDEPLOY_HOST_IP} -bind=${EASYDEPLOY_HOST_IP} -rejoin ${client_flag} || (sleep 20 && exit -1)