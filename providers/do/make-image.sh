#!/bin/bash -eux
cd $(dirname $0)
. ../../commands/common.sh
. ./do_common.sh

trap 'echo error "${BASH_SOURCE}" "${LINENO}" "$?" >&2; echo FAILED' ERR

if tugboat info_image -n $2  >&2
then
    $tugboat destroy_image -c -n $2  >&2
fi

$tugboat ssh --ssh-user=${USERNAME} -q --command="sudo poweroff" $1  >&2
while ! tugboat wait -s off $1  >&2
do
    echo "Waiting for poweroff." >&2
    sleep 5
done

sleep 5

$tugboat snapshot $2 $1 >&2
while ! tugboat wait $1   >&2
do
    echo "Waiting for machine to restart." >&2
    sleep 5
done
$tugboat info_image -n $2 | grep "ID:" | cut -d':' -f2 | tr -d ' '  || echo "FAILED"
