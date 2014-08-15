#!/bin/bash -x
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

touch /tmp/.started
OFFSET=$1
export EASYDEPLOY_WAIT_FOR=
export DOCKER_COMMANDS=
export EASYDEPLOY_PORTS=
export DOCKER_ARGS=
export EASYDEPLOY_STATE=stateful
export EASYDEPLOY_HOST_IP=$(</var/easydeploy/share/.config/ip)
set -eu

. /home/easydeploy/usr/etc/ezd.sh
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
        while ! dig +short "${service}.${PROJECT}.${DEPLOY_ENV}.comp.ezd"
        do
            echo "Awaiting $service resolution"
            sleep 10
        done

    done
fi

serf tags -set health=ok
docker run --rm=true  --sig-proxy=true -t -i $DOCKER_ARGS -v /var/easydeploy/container/$1:/var/local -v /var/easydeploy/share:/var/share -v /var/easydeploy/share:/var/easydeploy/share -e EASYDEPLOY_HOST_IP=${EASYDEPLOY_HOST_IP} --dns ${EASYDEPLOY_HOST_IP} ${DOCKER_IMAGE}:${DEPLOY_ENV} ${DOCKER_COMMANDS}
serf tags -set health=failed
