#!/bin/sh
set -ex
echo $DEPLOY_ENV
cd $(dirname $0) &> /dev/null
. common.sh
export MACHINE_NAME=$(mc_name)
export IP_ADDRESS=$(../providers/${PROVIDER}/provision.sh ${MACHINE_NAME} | tail -1)
if [ $IP_ADDRESS == "FAILED" ]
then
    echo "Failed to provision $MACHINE_NAME"
    exit -1
else
    ./deploy.sh ${IP_ADDRESS}
fi



