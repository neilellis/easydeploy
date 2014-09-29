#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

export OFFSET=$1
set -eux

. /home/easydeploy/bin/env.sh
for port in ${EASYDEPLOY_PORTS}
do
    export DOCKER_ARGS="$DOCKER_ARGS  -p ${EASYDEPLOY_HOST_IP}:$(($port + $OFFSET)):$(($port + $OFFSET))"
done
[ -d /var/easydeploy/container/$1 ] || mkdir -p /var/easydeploy/container/$1
[ -d /var/log/easydeploy/container/$1 ] || mkdir -p /var/log/easydeploy/container/$1
[ -d /var/easydeploy/container/$1/data ] || mkdir -p /var/easydeploy/container/$1/data


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
#    dockerLinks="${dockerLinks} --link datadog:datadog"
    :
fi



serf tags -set health=ok
cd ~/project
if [[ -f ~/ezd/bin/pre-build.sh ]]
then
    ./ezd/bin/pre-build.sh
fi

docker rmi ${DOCKER_IMAGE}:${DEPLOY_ENV}  || :
docker pull ${DOCKER_IMAGE}:${DEPLOY_ENV}
docker ps || (sudo service docker restart; sudo service supervisor restart;  exit -1 )
docker stop ${COMPONENT}-${OFFSET} || :

if [[ $EASYDEPLOY_STATE == "stateless" ]]
then
    trap "docker stop ${COMPONENT}-${OFFSET} || : ; docker rm --force ${COMPONENT}-${OFFSET} || : ; echo 'SIGTERM' ; exit 0" SIGTERM
    docker rm --force ${COMPONENT}-${OFFSET} || :
else
    trap "docker stop ${COMPONENT}-${OFFSET} || : ; echo 'SIGTERM' ; exit 0" SIGTERM
fi

weave_subnet="$(< /var/easydeploy/share/.config/weave_subnet)"
weave_ip="$(< /var/easydeploy/share/.config/weave_subnet).$(($1 + 100))"
weave_net="${weave_ip}/8"

export CONTAINER=$(sudo weave run ${weave_net} --name ${COMPONENT}-${1} -t -i --sig-proxy $DOCKER_ARGS -v /home/easydeploy/usr/etc/container:/var/easydeploy/etc -v /var/easydeploy/container/$1:/var/local -v /var/log/easydeploy/container/$1:/var/log/easydeploy -v /var/easydeploy/container/$1/data:/data -v /var/easydeploy/share:/var/share -v /var/easydeploy/share:/var/easydeploy/share -e EASYDEPLOY_HOST_IP=${EASYDEPLOY_HOST_IP} -e WEAVE_IP=${weave_ip} -e WEAVE_SUBNET=${weave_subnet} --dns ${EASYDEPLOY_HOST_IP} ${dockerLinks} ${DOCKER_IMAGE}:${DEPLOY_ENV} ${DOCKER_COMMANDS})
sudo docker-ns $CONTAINER route add -net 224.0.0.0 netmask 240.0.0.0 dev ethwe   || :
docker attach $CONTAINER

if [[ $EASYDEPLOY_STATE == "stateless" ]]
then
    docker rm --force $CONTAINER
fi

serf tags -set health=failed
