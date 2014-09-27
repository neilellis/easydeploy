#!/bin/bash -eu
for i in $(seq 1 10)
do
    if ! tugboat "$@"
    then
        echo "Tugboat error, retrying."
        sleep 60
    else
        exit 0
    fi
done
exit 1
