#!/bin/bash
shopt -s dotglob
export APP_ARGS=
#trap 'echo FAILED' ERR
cd $(dirname $0) &> /dev/null
. common.sh
export IP_ADDRESS=$1
echo "IP = $1"
set -eu

echo "************************** Public Key ****************************"
cat  ~/.ssh/easydeploy_id_rsa.pub
echo "******************************************************************"

[[ -f .ssh/known_hosts ]] && ssh-keygen -R ${IP_ADDRESS} || :
ssh  -qo "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "[ -d ~/.ssh ] || (echo | ssh-keygen -q -t rsa -N '' ) ; mkdir -p ~/remote/; mkdir -p ~/modules/ ; mkdir -p /var/easydeploy/share/sync/global/; [ -d ~/keys ] || mkdir ~/keys ;mkdir ~/project/ ; mkdir -p /var/easydeploy/share/deployer/"

sync ../remote/  ${USERNAME}@${IP_ADDRESS}:~/remote
[ -d ~/.ezd/modules/  ] && sync ~/.ezd/modules/  ${USERNAME}@${IP_ADDRESS}:~/modules/
[ -f ~/.dockercfg  ] && sync ~/.dockercfg   ${USERNAME}@${IP_ADDRESS}:~/.dockercfg
[ -d ~/.ezd/bin/  ] && sync ~/.ezd/bin/  ${USERNAME}@${IP_ADDRESS}:~/user-scripts/
[ -d ~/.ezd/etc/  ] && sync ~/.ezd/etc/  ${USERNAME}@${IP_ADDRESS}:~/user-config/

sync ${DIR}/*  ${USERNAME}@${IP_ADDRESS}:~/project/

scp  -qo "StrictHostKeyChecking no" ~/.ssh/easydeploy_* ${USERNAME}@${IP_ADDRESS}:~/.ssh/
scp  -qo "StrictHostKeyChecking no" ~/.ssh/id*.pub ${USERNAME}@${IP_ADDRESS}:~/keys

if [ ! -z "$PROVIDER" ]
then
    ../providers/${PROVIDER}/list-machines.sh > /tmp/ed-machine-list.txt
    scp  -qo "StrictHostKeyChecking no" /tmp/ed-machine-list.txt ${USERNAME}@${IP_ADDRESS}:~/machines.txt
fi
[ -d ~/.ezd/project/${PROJECT}/upload/bootstrap_sync/ ] && sync ~/.ezd/project/${PROJECT}/upload/bootstrap_sync/   ${USERNAME}@${IP_ADDRESS}:/var/easydeploy/share/sync/global/
[ -d ~/.ezd/project/${PROJECT}/upload/share/ ] && sync ~/.ezd/project/${PROJECT}/upload/share/   ${USERNAME}@${IP_ADDRESS}:/var/easydeploy/share/deployer/

scp -qo "StrictHostKeyChecking no" ~/.ezd/serf_key ${USERNAME}@${IP_ADDRESS}:~/serf_key

ssh  -qo "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "~/remote/bootstrap.sh  ${COMPONENT} ${DEPLOY_ENV} ${PROJECT} ${BACKUP_HOST} $(mc_name)  ${LB_TARGET_COMPONENT:-${COMPONENT}} ${REMOTE_IP_RANGE} \"${APP_ARGS}\" "







