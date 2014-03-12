#!/bin/sh
OFFSET=$1
export DOCKER_COMMANDS=
export EASYDEPLOY_PORTS=
export DOCKER_ARGS=
set -eu
. /home/easydeploy/config/ed.sh
for port in ${EASYDEPLOY_PORTS}
do
    export DOCKER_ARGS="$DOCKER_ARGS  -p $(($port + $OFFSET)):$(($port + $OFFSET))"
done
docker run -t -i  $DOCKER_ARGS --rm=true -dns 8.8.8.8 $(cat /home/easydeploy/.install-type) $DOCKER_COMMANDS
