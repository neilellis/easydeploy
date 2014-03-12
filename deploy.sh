#!/bin/sh

export GIT_URL_HOST=$1
export GIT_URL_USER=$2
export COMPONENT=$3
export IP_ADDRESS=$4
export USERBANE=$5
export DEPLOY_ENV=$6

echo "You may be prompted with a password a couple of times, make sure you have it ready :-)"
if [ -z "$2" ]
then
    echo "You must supply the environment dev,prod etc. that is being targeted." 1>&2
    exit -1
fi
set -eu
[ -f ~/.ssh/easydeploy_id_rsa ] || ssh-keygen -q -t rsa -N "" -f ~/.ssh/easydeploy_id_rsa
echo "Make sure the following key has access to your git repository:"
cat  ~/.ssh/easydeploy_id_rsa.pub
echo "Press Enter to continue"
read line
ssh  -o "StrictHostKeyChecking no" ${USERBANE}@${IP_ADDRESS} "[ -d ~/.ssh ] || ssh-keygen -q -t rsa -N """  &
scp  -o "StrictHostKeyChecking no" *  ${USERBANE}@${IP_ADDRESS}:~
scp  -o "StrictHostKeyChecking no" ~/.ssh/easydeploy_* ${USERBANE}@${IP_ADDRESS}:~/.ssh/
ssh  -o "StrictHostKeyChecking no" ${USERBANE}@${IP_ADDRESS} "./bootstrap.sh ${GIT_URL_HOST} ${GIT_URL_USER} ${COMPONENT} ${DEPLOY_ENV} ""$3"" &> /tmp/output.txt " &
ssh  -o "StrictHostKeyChecking no" ${USERBANE}@${IP_ADDRESS} "tail -F  /tmp/output.txt "


