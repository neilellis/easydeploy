#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eux
./rebuild-machines.sh
docker build -t ${DOCKER_IMAGE}:${DEPLOY_ENV} ${DIR}
docker push ${DOCKER_IMAGE}:${DEPLOY_ENV}

./create.sh