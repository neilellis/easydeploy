#!/bin/bash -eux
set -eu
cd $(dirname $0) &> /dev/null
[ -z "${MIN_INSTANCES}" ] && export MIN_INSTANCES=0
[ -z "${MAX_INSTANCES}" ] && export MAX_INSTANCES=1


cd $(dirname $0)
. common.sh
export MACHINE_NAME=$(mc_name)
set -eu

amount="$1"

if [[ $1 == "min" ]]
then
    amount=${MIN_INSTANCES}
fi

if [[ $1 == "max" ]]
then
    amount=${MAX_INSTANCES}
fi

if [[ ${amount} -gt ${MAX_INSTANCES} ]]
then
    echo "Exceeded instance limit of ${MAX_INSTANCES}"
    exit -1
fi

if [[ ${amount} -lt ${MIN_INSTANCES} ]]
then
    echo "Cannot scale below ${MIN_INSTANCES}"
    exit -1
fi

../providers/${PROVIDER}/scale.sh $amount





