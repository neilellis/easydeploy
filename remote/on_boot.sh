#!/bin/bash -eu
. /ezbin/env.sh

/home/easydeploy/bin/clean.sh

if [[ $EASYDEPLOY_STATE == "stateless" ]]
then
    docker rmi ${DOCKER_IMAGE}:${DEPLOY_ENV}
    docker pull ${DOCKER_IMAGE}:${DEPLOY_ENV}
fi
