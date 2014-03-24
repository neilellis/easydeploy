#!/bin/sh
if ! which tugboat
then
    sudo gem install tugboat
fi
cd $(dirname $0)
. ../../commands/common.sh

MACHINE_NAME=$(machineName)
ids=$(tugboat droplets | grep "${MACHINE_NAME} " |  cut -d":" -f5| tr -d ')' )
for id in $ids
do
    echo "Rebuilding $MACHINE_NAME ($id)"
    tugboat rebuild -c -m $(templateName) -i $id
    tugboat wait -s off -i $id
    tugboat wait -i $id
    sleep 30
done
