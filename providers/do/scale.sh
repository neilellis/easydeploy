#!/bin/sh
trap 'echo FAILED' ERR

if [ $# -eq 2 ]
then
    cd $(dirname $1)
    export ENV_FILE=$(pwd)/$1
    cd -
    source $ENV_FILE
    shift
fi

[ -z "${MIN_INSTANCES}" ] && export MIN_INSTANCES=0
[ -z "${MAX_INSTANCES}" ] && export MAX_INSTANCES=1


cd $(dirname $0)
. ../../commands/common.sh
MACHINE_NAME=$(machineName)
set -eux


if [ $1 -gt ${MAX_INSTANCES} ]
then
    echo "Exceeded instance limit of ${MAX_INSTANCES}"
    exit -1
fi

if [ $1 -lt ${MIN_INSTANCES} ]
then
    echo "Cannot scale below ${MIN_INSTANCES}"
    exit -1
fi

start=$(echo $(tugboat droplets | grep "${MACHINE_NAME} " | wc -l) +1 | bc)

for i in $(seq $start $1)
do
tugboat create --quiet --size=${DO_IMAGE_SIZE} --image=${DO_BASE_IMAGE} --region=${DO_REGION}  --keys=${DO_KEYS} --private-networking  $MACHINE_NAME
done
