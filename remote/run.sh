#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

OFFSET=$1
export EASYDEPLOY_WAIT_FOR=
export DOCKER_COMMANDS=
export EASYDEPLOY_PORTS=
export DOCKER_ARGS=
export EASYDEPLOY_STATE=stateful
export EASYDEPLOY_HOST_IP=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
set -eu

. /home/easydeploy/deployment/ed.sh
DEPLOY_ENV=$(cat /var/easydeploy/share/.config/deploy_env)
PROJECT=$(cat /var/easydeploy/share/.config/project)
for port in ${EASYDEPLOY_PORTS}
do
    export DOCKER_ARGS="$DOCKER_ARGS  -p ${EASYDEPLOY_HOST_IP}:$(($port + $OFFSET)):$(($port + $OFFSET))"
done
[ -f /var/easydeploy/container/$1 ] || mkdir -p /var/easydeploy/container/$1

if [ ! -z "$EASYDEPLOY_WAIT_FOR" ]
then
    for service in ${EASYDEPLOY_WAIT_FOR}
    do
        while ! dig +short "${DEPLOY_ENV}-${PROJECT}-${service}.service.easydeploy"
        do
            echo "Awaiting $service resolution"
            sleep 10
        done

    done
fi

docker run --rm=true  --sig-proxy=true -t -i $DOCKER_ARGS -v /var/easydeploy/container/$1:/var/local -v /var/easydeploy/share:/var/share -v /var/easydeploy/share:/var/easydeploy/share -e EASYDEPLOY_HOST_IP=${EASYDEPLOY_HOST_IP} --dns ${EASYDEPLOY_HOST_IP} $(cat /var/easydeploy/share/.config/component) $DOCKER_COMMANDS