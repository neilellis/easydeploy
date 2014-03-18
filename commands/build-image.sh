#!/bin/sh
if [ $# -eq 1 ]
then
export ENV_FILE=$1
source $ENV_FILE
fi
set -eu
cd $(dirname $0) &> /dev/null
export TIMESTAMP=$(date +%s)
export MACHINE_NAME="template-${GIT_URL_USER}-${COMPONENT}-${TIMESTAMP}"
export IP_ADDRESS=$(../providers/${PROVIDER}/provision.sh ${MACHINE_NAME} | tail -1)
if [ $IP_ADDRESS == "FAILED" ]
then
    echo "Failed to provision $MACHINE_NAME"
    exit -1
else
    ./deploy.sh ${IP_ADDRESS}
    export IMAGE=$(../providers/${PROVIDER}/make-image.sh ${MACHINE_NAME} template-${GIT_URL_USER}-${COMPONENT}  ${IP_ADDRESS} | tail -1)
    sleep 30
    ../providers/${PROVIDER}/deprovision.sh ${MACHINE_NAME}
    if [ $IMAGE == "FAILED" ]
    then
        echo "Failed to create image template-${GIT_URL_USER}-${COMPONENT}"
        exit -1
    else
        echo "Image created on ${PROVIDER} was ${IMAGE}"
        exit 0
    fi

fi



