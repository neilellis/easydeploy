#!/bin/sh
set -u
if ! which tugboat > /dev/null
then
   echo "Please install tugboat using 'gem install tugboat'"
fi
MACHINE_NAME="${DEPLOY_ENV}-${GIT_URL_USER}-${COMPONENT}"
tugboat droplets | grep "${MACHINE_NAME} " |  cut -d":" -f2| tr -d ')' | cut -d, -f1 | tr -d ' '
