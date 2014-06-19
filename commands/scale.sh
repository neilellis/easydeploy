#!/bin/sh
set -eu
cd $(dirname $0) &> /dev/null
[ -z "${MIN_INSTANCES}" ] && export MIN_INSTANCES=0
[ -z "${MAX_INSTANCES}" ] && export MAX_INSTANCES=1


cd $(dirname $0)
. common.sh
export MACHINE_NAME=$(mc_name)
set -eu


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

../providers/${PROVIDER}/scale.sh $1





