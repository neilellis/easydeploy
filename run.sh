#!/bin/sh
OFFSET=$1
export DOCKER_COMMANDS=
export EASYDEPLOY_PORTS=
export DOCKER_ARGS=
set -eu
. /home/easydeploy/config/ed.sh
if [[ ${EASYDEPLOY_STATE} == "stateless" ]]
then
    export DOCKER_ARGS="$DOCKER_ARGS --rm==true"
fi
for port in ${EASYDEPLOY_PORTS}
do
    export DOCKER_ARGS="$DOCKER_ARGS  -p $(($port + $OFFSET)):$(($port + $OFFSET))"
done
[ -f /var/easydeploy/container/$1 ] || mkdir -p /var/easydeploy/container/$1
docker run -t -i  $DOCKER_ARGS -v /var/easydeploy/container/$1:/var/easydeploy -dns 8.8.8.8 $(cat /home/easydeploy/.install-type) $DOCKER_COMMANDS
