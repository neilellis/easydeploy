#!/bin/sh
trap 'echo FAILED' ERR

set -eux
if ! which tugboat
then
    sudo gem install tugboat
fi

if tugboat info_image $2
then
    tugboat destroy_image -c $2
fi

tugboat ssh --ssh-user=${USERNAME} -q -c "poweroff" $1
tugboat wait -s off $1
sleep 5
tugboat snapshot $2 $1
tugboat wait $1
tugboat info_image $2 | grep "ID:" | cut -d':' -f2 | tr -d ' '
