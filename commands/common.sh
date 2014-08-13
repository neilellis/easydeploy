#!/bin/sh

function template_name()  {
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

function mc_name() {
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

function mc_name_for_env() {
    if [[ ! -z "$LB_TARGET_COMPONENT" ]]
    then
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${1}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}-lb"
        else
            echo "${1}-${PROJECT}-${LB_TARGET_COMPONENT}-lb"
        fi
    else
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${1}-${PROJECT}-${COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "${1}-${PROJECT}-${COMPONENT}"
        fi
    fi
}

function projectMachinePrefix() {
    echo "${DEPLOY_ENV}-${PROJECT}-"
}


function targetmc_name() {
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}"
        fi
}

function sync() {
    rsync --rsh="/usr/bin/ssh -o 'StrictHostKeyChecking no' " --compress \
     --recursive --times --perms --links \
     --exclude ".Sync*"  \
     "$@"
}

