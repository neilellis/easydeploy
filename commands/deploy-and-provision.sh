#!/bin/sh
if [ $# -eq 1 ]
then
cd $(dirname $1)
export ENV_FILE=$(pwd)/$1
cd -
source $ENV_FILE
fi
set -eu
cd $(dirname $0) &> /dev/null
export MACHINE_NAME="${DEPLOY_ENV}-${GIT_URL_USER}-${COMPONENT}"
export IP_ADDRESS=$(../providers/${PROVIDER}/provision.sh ${MACHINE_NAME} | tail -1)
if [ $IP_ADDRESS == "FAILED" ]
then
    echo "Failed to provision $MACHINE_NAME"
    exit -1
else
    ./deploy.sh ${IP_ADDRESS}
fi



