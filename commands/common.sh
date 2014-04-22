#!/bin/sh

function templateName()  {
 if [[ ! -z "$LB_TARGET_COMPONENT" ]]
    then
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "template-${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}-lb"
        else
            echo "template-${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}-lb"
        fi
    else
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "template-${DEPLOY_ENV}-${PROJECT}-${COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "template-${DEPLOY_ENV}-${PROJECT}-${COMPONENT}"
        fi
    fi
}

function machineName() {
    if [[ ! -z "$LB_TARGET_COMPONENT" ]]
    then
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}-lb"
        else
            echo "${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}-lb"
        fi
    else
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${DEPLOY_ENV}-${PROJECT}-${COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "${DEPLOY_ENV}-${PROJECT}-${COMPONENT}"
        fi
    fi
}

function projectMachinePrefix() {
    echo "${DEPLOY_ENV}-${PROJECT}-"
}


function targetMachineName() {
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}"
        fi
}

function sync() {
    rsync --progress --rsh="/usr/bin/ssh -o 'StrictHostKeyChecking no' " --compress \
     --recursive --times --perms --links \
     --exclude ".Sync*"  \
     "$@"
}