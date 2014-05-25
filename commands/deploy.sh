#!/bin/bash
export APP_ARGS=
trap 'echo FAILED' ERR
cd $(dirname $0) &> /dev/null
. common.sh
export IP_ADDRESS=$1
echo "IP = $1"
set -eu


echo "************************** Public Key ****************************"
cat  ~/.ssh/easydeploy_id_rsa.pub
echo "******************************************************************"

ssh  -qo "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "[ -d ~/.ssh ] || (echo | ssh-keygen -q -t rsa -N '' ) ; mkdir -p ~/modules/ ; mkdir -p /var/easydeploy/share/sync/global/; mkdir ~/keys ; mkdir -p /var/easydeploy/share/deployer/"
sync ../remote/  ${USERNAME}@${IP_ADDRESS}:~/
[ -d ~/.ezd/modules/  ] && sync ~/.ezd/modules/  ${USERNAME}@${IP_ADDRESS}:~/modules/
[ -d ~/.ezd/user-scripts/  ] && sync ~/.ezd/user-scripts/  ${USERNAME}@${IP_ADDRESS}:~/user-scripts/
[ -d ~/.ezd/user-config/  ] && sync ~/.ezd/user-config/  ${USERNAME}@${IP_ADDRESS}:~/user-config/
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

ssh  -qo "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "./bootstrap.sh ${GIT_URL_HOST} ${GIT_URL_USER} ${COMPONENT} ${DEPLOY_ENV} ${GIT_BRANCH} ${PROJECT} ${BACKUP_HOST} $(machineName)  ${LB_TARGET_COMPONENT:-${COMPONENT}} ${REMOTE_IP_RANGE} \"${APP_ARGS}\" "







