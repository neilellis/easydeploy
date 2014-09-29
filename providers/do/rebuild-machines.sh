#!/bin/bash -eux
cd $(dirname $0)
. ../../commands/common.sh
. ./do_common.sh

export MACHINE_NAME=$(mc_name)

function droplets() {
    $tugboat droplets | grep "^${MACHINE_NAME} " |  cut -d":" -f5| tr -d ')' | tr -d ' '
}

#export image=$($tugboat image | grep "^$(template_name) " |  cut -d":" -f2| tr -d ')' | cut -d, -f1 | tr -d ' ' | tail -1)


function rebuild() {
    echo "Rebuilding $MACHINE_NAME ($1)"
    for i in $(seq 1 60)
    do
        tugboat halt -c -i $1 || :
        tugboat wait -i $1 -s off
        if tugboat rebuild -c -k ${DO_BASE_IMAGE} -i $1
         then
            break;
         else
            sleep 30
         fi
        echo "Retrying rebuild."
    done
    echo "Waiting for image change."
    while (( $($tugboat info -i $1 | grep "Image ID:" | cut -d: -f2 | tr -d ' ') != ${DO_BASE_IMAGE} ))
     do
        echo -n "."
        sleep 5
     done
    echo
    $tugboat wait -i $1
}

export -f rebuild

if [ -z "${USE_PARALLEL}" ]
then
    droplets | while read m; do rebuild $m ; done
else
    droplets | parallel --gnu -P 0 --no-run-if-empty "rebuild {} "
fi
sleep 30

./do_to_cf.sh




