#!/bin/bash
export APP_ARGS=
trap 'echo FAILED' ERR
cd $(dirname $0) &> /dev/null
export IP_ADDRESS=$1
echo "IP = $1"
set -eu

echo "You may be prompted with a password a couple of times, make sure you have it ready :-)"
[ -f ~/.ssh/easydeploy_id_rsa ] || (ssh-keygen -q -t rsa -N "" -f ~/.ssh/easydeploy_id_rsa && echo "FIRST RUN!! Make sure the following key has access to your git repository, you'll have problems if not. Run this script again now that we've generated your key." && cat  ~/.ssh/easydeploy_id_rsa.pub && exit 0)

echo "************************** Public Key ****************************"
cat  ~/.ssh/easydeploy_id_rsa.pub
echo "******************************************************************"

ssh  -o "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "[ -d ~/.ssh ] || (echo | ssh-keygen -q -t rsa -N '' ) ; mkdir -p ~/modules/"
scp  -o "StrictHostKeyChecking no" -r ../remote/*  ${USERNAME}@${IP_ADDRESS}:~
[ -f ~/.edmods ] && scp  -o "StrictHostKeyChecking no" -r ~/.edmods/*  ${USERNAME}@${IP_ADDRESS}:~/modules/
scp  -o "StrictHostKeyChecking no" ~/.ssh/easydeploy_* ${USERNAME}@${IP_ADDRESS}:~/.ssh/
if [ ! -z "$PROVIDER" ]
then
 ../providers/${PROVIDER}/list-machines.sh > /tmp/ed-machine-list.txt
    scp  -o "StrictHostKeyChecking no" /tmp/ed-machine-list.txt ${USERNAME}@${IP_ADDRESS}:~/machines.txt
fi
ssh  -o "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "./bootstrap.sh ${GIT_URL_HOST} ${GIT_URL_USER} ${COMPONENT} ${DEPLOY_ENV} ${GIT_BRANCH} \"${APP_ARGS}\" "





