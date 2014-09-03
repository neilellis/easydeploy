#!/bin/bash -eux
cd $(dirname $0)
. ../../commands/common.sh
. ./do_common.sh

MACHINE_NAME=$(mc_name)

function droplets() {
    tugboat droplets | grep "^${MACHINE_NAME} " |  cut -d":" -f5| tr -d ')' | tr -d ' '
}

export image=$(tugboat image | grep "^$(template_name) " |  cut -d":" -f2| tr -d ')' | cut -d, -f1 | tr -d ' ' | tail -1)


function rebuild() {
    echo "Rebuilding $MACHINE_NAME ($1)"
    for i in $(seq 1 10)
    do
        if tugboat rebuild -c -k $2 -i $1
         then
            break;
         else
            sleep 30
         fi
        echo "Retrying rebuild."
    done
    echo "Waiting for image change."
    while (( $(tugboat info -i $1 | grep "Image ID:" | cut -d: -f2 | tr -d ' ') != ${image} ))
     do
        echo -n "."
        sleep 5
     done
    echo
    while ! tugboat wait -i $1
    do
        echo "Waiting for $1"
        sleep 60
    done
}

export -f rebuild

if [ -z "${USE_PARALLEL}" ]
then
    droplets | while read m; do rebuild $m $image; done
else
    droplets | parallel --gnu -P 0 --no-run-if-empty "rebuild {} $image"
fi
sleep 30



