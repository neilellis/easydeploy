#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

export EASYDEPLOY_WAIT_FOR=
export DOCKER_COMMANDS=
export EASYDEPLOY_PORTS=
export DOCKER_ARGS=
export EASYDEPLOY_STATE=stateful

export DEPLOY_ENV=$(cat /var/easydeploy/share/.config/deploy_env)
export PROJECT=$(cat /var/easydeploy/share/.config/project)
export COMPONENT=$(cat /var/easydeploy/share/.config/component)
export HOST=$(cat /var/easydeploy/share/.config/hostname)
export IP=$(cat /var/easydeploy/share/.config/ip)
export EASYDEPLOY_HOST_IP=${IP}

. /home/easydeploy/project/ezd/etc/ezd.sh