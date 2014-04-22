#!/bin/sh
set -e
cd $(dirname $0) &> /dev/null
. common.sh
export MACHINE_NAME=$(templateName)-$(date +%s)

export IP_ADDRESS=$(../providers/${PROVIDER}/provision.sh $@ ${MACHINE_NAME} | tail -1)
if [ "$IP_ADDRESS" == "FAILED" ]
then
    echo "Failed to provision $MACHINE_NAME"
    exit -1
else
    ./deploy.sh ${IP_ADDRESS}
    export IMAGE=$(../providers/${PROVIDER}/make-image.sh ${MACHINE_NAME} $(templateName) ${IP_ADDRESS} | tail -1)
    sleep 30
    ../providers/${PROVIDER}/deprovision.sh ${MACHINE_NAME}
    if [ $IMAGE == "FAILED" ]
    then
        echo "Failed to create image ${MACHINE_NAME}"
        exit -1
    else
        echo "Image created on ${PROVIDER} was ${IMAGE}"
        exit 0
    fi

fi



