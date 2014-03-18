#!/bin/sh
set +u
function templateName()
if [ ! -z "$COMPONENT_MODIFIER" ]
then
    echo "template-${GIT_URL_USER}-${COMPONENT}-${COMPONENT_MODIFIER}-${TIMESTAMP}"
else
    echo "template-${GIT_URL_USER}-${COMPONENT}-${TIMESTAMP}"
fi

function machineName() {
if [ ! -z "$COMPONENT_MODIFIER" ]
then
    echo "${DEPLOY_ENV}-${GIT_URL_USER}-${COMPONENT}-${COMPONENT_MODIFIER}"
else
    echo "${DEPLOY_ENV}-${GIT_URL_USER}-${COMPONENT}"
fi
}

set -u