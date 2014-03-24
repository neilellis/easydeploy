#!/bin/sh

function templateName()  {
 if [[ ! -z "$LB_TARGET_COMPONENT" ]]
    then
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "template-${LB_TARGET_USER}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}-lb"
        else
            echo "template-${LB_TARGET_USER}-${LB_TARGET_COMPONENT}-lb"
        fi
    else
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "template-${GIT_URL_USER}-${COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "template-${GIT_URL_USER}-${COMPONENT}"
        fi
    fi
}

function machineName() {
    if [[ ! -z "$LB_TARGET_COMPONENT" ]]
    then
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${DEPLOY_ENV}-${LB_TARGET_USER}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}-lb"
        else
            echo "${DEPLOY_ENV}-${LB_TARGET_USER}-${LB_TARGET_COMPONENT}-lb"
        fi
    else
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${DEPLOY_ENV}-${GIT_URL_USER}-${COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "${DEPLOY_ENV}-${GIT_URL_USER}-${COMPONENT}"
        fi
    fi
}



function targetMachineName() {
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${DEPLOY_ENV}-${LB_TARGET_USER}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "${DEPLOY_ENV}-${LB_TARGET_USER}-${LB_TARGET_COMPONENT}"
        fi
}
