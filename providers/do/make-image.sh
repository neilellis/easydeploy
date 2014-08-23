#!/bin/bash -eu
trap 'echo FAILED' ERR

if tugboat info_image -n $2
then
    tugboat destroy_image -c -n $2
fi

tugboat ssh --ssh-user=${USERNAME} -q -c "sudo poweroff" $1
while ! tugboat wait -s off $1
do
    echo "Waiting for poweroff."
    sleep 5
done

sleep 5

tugboat snapshot $2 $1
while ! tugboat wait $1
do
    echo "Waiting for machine to restart."
    sleep 5
done
tugboat info_image -n $2 | grep "ID:" | cut -d':' -f2 | tr -d ' '
