#!/bin/sh
trap 'echo FAILED' ERR
if [ $# -eq 2 ]
then
    cd $(dirname $1)
    export ENV_FILE=$(pwd)/$1
    cd -
    source $ENV_FILE
    shift
fi
cd $(dirname $0) &> /dev/null
export OTHER_ARGS=$2
export IP_ADDRESS=$1
echo "IP = $1"
set -eu

echo "You may be prompted with a password a couple of times, make sure you have it ready :-)"
[ -f ~/.ssh/easydeploy_id_rsa ] || (ssh-keygen -q -t rsa -N "" -f ~/.ssh/easydeploy_id_rsa && echo "FIRST RUN!! Make sure the following key has access to your git repository, you'll have problems if not. Run this script again now that we've generated your key." && cat  ~/.ssh/easydeploy_id_rsa.pub && exit 0)

echo "************************** Public Key ****************************"
cat  ~/.ssh/easydeploy_id_rsa.pub
echo "******************************************************************"

ssh  -o "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "[ -d ~/.ssh ] || ssh-keygen -q -t rsa -N "" ; mkdir -p ~/modules/"  &
scp  -o "StrictHostKeyChecking no" -r remote/*  ${USERNAME}@${IP_ADDRESS}:~
[ -f ~/.edmods ] && scp  -o "StrictHostKeyChecking no" -r ~/.edmods/*  ${USERNAME}@${IP_ADDRESS}:~/modules/
scp  -o "StrictHostKeyChecking no" -r modules/*  ${USERNAME}@${IP_ADDRESS}:~/modules/
scp  -o "StrictHostKeyChecking no" ~/.ssh/easydeploy_* ${USERNAME}@${IP_ADDRESS}:~/.ssh/
ssh  -o "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "./bootstrap.sh ${GIT_URL_HOST} ${GIT_URL_USER} ${COMPONENT} ${DEPLOY_ENV} \"${OTHER_ARGS}\" "



