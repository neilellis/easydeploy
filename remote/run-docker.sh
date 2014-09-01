#!/bin/bash -x
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

export OFFSET=$1
set -eu

. /home/easydeploy/bin/env.sh
for port in ${EASYDEPLOY_PORTS}
do
    export DOCKER_ARGS="$DOCKER_ARGS  -p ${EASYDEPLOY_HOST_IP}:$(($port + $OFFSET)):$(($port + $OFFSET))"
done
[ -d /var/easydeploy/container/$1 ] || mkdir -p /var/easydeploy/container/$1
[ -d /var/log/easydeploy/container/$1 ] || mkdir -p /var/log/easydeploy/container/$1

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


#fig up

dockerLinks=
if [[ $DEPLOY_ENV == "prod" ]]  && [[ -f /home/easydeploy/project/ezd/etc/datadog-agent-image.txt ]]
then
    dockerLinks="${dockerLinks} --link datadog:datadog"
fi



serf tags -set health=ok
cd ~/project
if [[ -f ~/ezd/bin/pre-build.sh ]]
then
    ./ezd/bin/pre-build.sh
fi
docker pull ${DOCKER_IMAGE}:${DEPLOY_ENV}
if [[ -f Dockerfile ]]
then
    docker build -t ${DOCKER_IMAGE}:${DEPLOY_ENV}   .
fi

docker stop ${COMPONENT}-${OFFSET} || :
docker rm --force ${COMPONENT}-${OFFSET} || :
trap "docker stop ${COMPONENT}-${OFFSET} || : ; docker rm --force ${COMPONENT}-${OFFSET} || : ; echo 'SIGTERM' ; exit 0" SIGTERM

docker run --name ${COMPONENT}-${1} --rm=true  --sig-proxy=true -t -i $DOCKER_ARGS -v /var/easydeploy/container/$1:/var/local -v /var/log/easydeploy/container/$1:/var/log/easydeploy -v /var/easydeploy/share:/var/share -v /var/easydeploy/share:/var/easydeploy/share -e EASYDEPLOY_HOST_IP=${EASYDEPLOY_HOST_IP} --dns ${EASYDEPLOY_HOST_IP} ${dockerLinks} ${DOCKER_IMAGE}:${DEPLOY_ENV} ${DOCKER_COMMANDS}

serf tags -set health=failed
