#!/bin/bash -eu

deployEnvMod="${1}"
if [[ ! -z "$ENVIRONMENT_MODIFIER" ]]
then
    deployEnvMod="${deployEnvMod}-$ENVIRONMENT_MODIFIER"
fi

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
    mc_name_for_env "${DEPLOY_ENV}"

}

function mc_name_for_env() {
    deployEnvMod="${1}"
    if [[ ! -z "$ENVIRONMENT_MODIFIER" ]]
    then
        deployEnvMod="${deployEnvMod}-$ENVIRONMENT_MODIFIER"
    fi
    if [[ ! -z "$LB_TARGET_COMPONENT" ]]
    then
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${deployEnvMod}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}-lb"
        else
            echo "${deployEnvMod}-${PROJECT}-${LB_TARGET_COMPONENT}-lb"
        fi
    else
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${deployEnvMod}-${PROJECT}-${COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "${deployEnvMod}-${PROJECT}-${COMPONENT}"
        fi
    fi
}

function projectMachinePrefix() {
    echo "${deployEnvMod}-${PROJECT}-"
}


function targetmc_name() {
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${deployEnvMod}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "${deployEnvMod}-${PROJECT}-${LB_TARGET_COMPONENT}"
        fi
}

function sync() {
    rsync --rsh="/usr/bin/ssh -o 'StrictHostKeyChecking no' " --quiet --recursive --times --perms --links  --exclude ".Sync*"  "$@"
}

