#!/bin/sh
set -u
if ! which tugboat
then
    sudo gem install tugboat
fi
MACHINE_NAME="${DEPLOY_ENV}-${GIT_URL_USER}-${COMPONENT}"
ids=$(tugboat droplets | grep "${MACHINE_NAME} " |  cut -d":" -f5| tr -d ')' )
for id in $ids
do
    echo "Rebuilding $MACHINE_NAME ($id)"
    tugboat rebuild -c -m "template-${GIT_URL_USER}-${COMPONENT}" -i $id
    tugboat wait -s off -i $id
    tugboat wait -i $id
    sleep 30
done
