#!/bin/sh
OFFSET=$1
export DOCKER_COMMANDS=
export EASYDEPLOY_PORTS=
export DOCKER_ARGS=
export EASYDEPLOY_STATE=stateful
export EASYDEPLOY_HOST_IP=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
set -eu

. /home/easydeploy/deployment/ed.sh
if [ "${EASYDEPLOY_STATE}" = "stateless" ]
then
    export DOCKER_ARGS="$DOCKER_ARGS --rm=true"
fi
for port in ${EASYDEPLOY_PORTS}
do
    export DOCKER_ARGS="$DOCKER_ARGS  -p $ip:$(($port + $OFFSET)):$(($port + $OFFSET))"
done
[ -f /var/easydeploy/container/$1 ] || mkdir -p /var/easydeploy/container/$1
echo | docker run --sig-proxy=true  $DOCKER_ARGS -v /var/easydeploy/container/$1:/var/local -v /var/easydeploy/share:/var/share -e EASYDEPLOY_HOST_IP=$ip --dns 8.8.8.8 $(cat /var/easydeploy/share/.config/component) $DOCKER_COMMANDS