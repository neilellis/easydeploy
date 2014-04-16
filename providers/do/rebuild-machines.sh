#!/bin/bash
cd $(dirname $0)
. ../../commands/common.sh

MACHINE_NAME=$(machineName)

function droplets() {
    tugboat droplets | grep "^${MACHINE_NAME} " |  cut -d":" -f5| tr -d ')' | tr -d ' '
}

export image=$(tugboat image | grep "^$(templateName) " |  cut -d":" -f2| tr -d ')' | cut -d, -f1 | tail -1)


function rebuild() {
    echo "Rebuilding $MACHINE_NAME ($1)"
    for i in $(seq 1 10)
    do
        (tugboat rebuild -c -k $2 -i $1 && break) ||  sleep 60
        echo "Retrying rebuild."
    done
    tugboat wait -s off -i $1
    tugboat wait -i $1
    sleep 30
}

export -f rebuild

droplets | parallel --gnu -P 0 --no-run-if-empty "rebuild {} $image"


