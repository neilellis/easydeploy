#!/bin/bash
shopt -s dotglob
export APP_ARGS=
#trap 'echo FAILED' ERR
cd $(dirname $0) &> /dev/null
. common.sh
export IP_ADDRESS=$1
echo "IP = $1"
set -eux

ssh  -qo "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "~/remote/bootstrap.sh ${DATACENTER} ${COMPONENT} ${DEPLOY_ENV} ${PROJECT} ${BACKUP_HOST} $(mc_name)  ${LB_TARGET_COMPONENT:-${COMPONENT}} ${REMOTE_IP_RANGE} \"${APP_ARGS}\" "
