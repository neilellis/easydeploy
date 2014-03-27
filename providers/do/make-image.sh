#!/bin/bash -x
trap 'echo FAILED' ERR

if tugboat info_image -n $2
then
    tugboat destroy_image -c -n $2
fi

tugboat ssh --ssh-user=${USERNAME} -q -c "sudo poweroff" $1
tugboat wait -s off $1
sleep 5
tugboat snapshot $2 $1
tugboat wait $1
tugboat info_image -n $2 | grep "ID:" | cut -d':' -f2 | tr -d ' '
