#!/bin/bash
shopt -s dotglob
export APP_ARGS=
#trap 'echo FAILED' ERR
cd $(dirname $0) &> /dev/null
. common.sh
export IP_ADDRESS=$1
echo "IP = $1"
set -eux

echo "************************** Public Key ****************************"
cat  ~/.ssh/easydeploy_id_rsa.pub
echo "******************************************************************"

if [[ -f .ssh/known_hosts ]]
then
    ssh-keygen -R ${IP_ADDRESS}
fi

rssh  ${USERNAME}@${IP_ADDRESS} "[ -d ~/.ssh ] || (echo | ssh-keygen -q -t rsa -N '' ) ; mkdir -p ~/remote/; mkdir -p ~/modules/ ; mkdir -p /var/easydeploy/share/sync/global/; [ -d ~/keys ] || mkdir ~/keys ;mkdir ~/project/ ; mkdir -p /var/easydeploy/share/deployer/"

sync ../remote/  ${USERNAME}@${IP_ADDRESS}:~/remote/

if [ -d ~/.ezd/modules/  ]
then
    sync ~/.ezd/modules/  ${USERNAME}@${IP_ADDRESS}:~/modules/
fi

if [ -f ~/.dockercfg  ]
then
    rscp ~/.dockercfg   ${USERNAME}@${IP_ADDRESS}:~/.dockercfg
fi

if [ -d ~/.ezd/bin/  ]
then
    sync ~/.ezd/bin/  ${USERNAME}@${IP_ADDRESS}:~/user-scripts/
fi

if [ -d ~/.ezd/etc/  ]
then
    sync ~/.ezd/etc/  ${USERNAME}@${IP_ADDRESS}:~/user-config/
fi

sync ${DIR}/*  ${USERNAME}@${IP_ADDRESS}:~/project/

rscp   ~/.ssh/easydeploy_* ${USERNAME}@${IP_ADDRESS}:~/.ssh/
rscp   ~/.ssh/id*.pub ${USERNAME}@${IP_ADDRESS}:~/keys

if [ ! -z "$PROVIDER" ]
then
    ../providers/${PROVIDER}/list-machines.sh > /tmp/ed-machine-list.txt
    rscp  /tmp/ed-machine-list.txt ${USERNAME}@${IP_ADDRESS}:~/machines.txt
fi
if [ -d ~/.ezd/project/${PROJECT}/upload/bootstrap_sync/ ]
then
    sync ~/.ezd/project/${PROJECT}/upload/bootstrap_sync/   ${USERNAME}@${IP_ADDRESS}:/var/easydeploy/share/sync/global/
fi
if [ -d ~/.ezd/project/${PROJECT}/upload/share/ ]
then
    sync ~/.ezd/project/${PROJECT}/upload/share/   ${USERNAME}@${IP_ADDRESS}:/var/easydeploy/share/deployer/
fi

rscp  ~/.ezd/serf_key ${USERNAME}@${IP_ADDRESS}:~/serf_key

docker build -t ${DOCKER_IMAGE} ${DIR}
docker push ${DOCKER_IMAGE}

ssh  -qo "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "~/remote/bootstrap.sh ${DATACENTER} ${COMPONENT} ${DEPLOY_ENV} ${PROJECT} ${BACKUP_HOST} $(mc_name)  ${LB_TARGET_COMPONENT:-${COMPONENT}} ${REMOTE_IP_RANGE} \"${APP_ARGS}\" "







