#!/bin/bash -eu


function template_name()  {
 if [[ ! -z "$LB_TARGET_COMPONENT" ]]
    then
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "template-${DATACENTER}-${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}-lb"
        else
            echo "template-${DATACENTER}-${DEPLOY_ENV}-${PROJECT}-${LB_TARGET_COMPONENT}-lb"
        fi
    else
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "template-${DATACENTER}-${DEPLOY_ENV}-${PROJECT}-${COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "template-${DATACENTER}-${DEPLOY_ENV}-${PROJECT}-${COMPONENT}"
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
            echo "${DATACENTER}-${deployEnvMod}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}-lb"
        else
            echo "${DATACENTER}-${deployEnvMod}-${PROJECT}-${LB_TARGET_COMPONENT}-lb"
        fi
    else
        if [[ ! -z "$COMPONENT_MODIFIER" ]]
        then
            echo "${DATACENTER}-${deployEnvMod}-${PROJECT}-${COMPONENT}-${COMPONENT_MODIFIER}"
        else
            echo "${DATACENTER}-${deployEnvMod}-${PROJECT}-${COMPONENT}"
        fi
    fi
}

function projectMachinePrefix() {
    deployEnvMod="${DEPLOY_ENV}"
    if [[ ! -z "$ENVIRONMENT_MODIFIER" ]]
    then
        deployEnvMod="${deployEnvMod}-$ENVIRONMENT_MODIFIER"
    fi

    echo "${DATACENTER}-${deployEnvMod}-${PROJECT}-"
}


function targetmc_name() {
    deployEnvMod="${DEPLOY_ENV}"
    if [[ ! -z "$ENVIRONMENT_MODIFIER" ]]
    then
        deployEnvMod="${DATACENTER}-${deployEnvMod}-$ENVIRONMENT_MODIFIER"
    fi
    if [[ ! -z "$COMPONENT_MODIFIER" ]]
    then
        echo "${DATACENTER}-${deployEnvMod}-${PROJECT}-${LB_TARGET_COMPONENT}-${COMPONENT_MODIFIER}"
    else
        echo "${DATACENTER}-${deployEnvMod}-${PROJECT}-${LB_TARGET_COMPONENT}"
    fi
}

function sync() {
    while ! rsync --rsh="/usr/bin/ssh -o 'StrictHostKeyChecking no' " --quiet --recursive --checksum --perms --links --delete-after  --exclude ".Sync*"  "$@"
    do
        echo "rsync failed, retrying ...."
        sleep 20
    done
}

function rssh() {
    while ! ssh -qo 'StrictHostKeyChecking no' $@
    do
        echo "ssh failed, retrying ...."
        sleep 20
    done
}

function rscp() {
    while ! scp -qo 'StrictHostKeyChecking no' $@
    do
        echo "scp failed, retrying ...."
        sleep 20
    done
}



export -f sync

