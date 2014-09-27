#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eux
./destroy.sh
while (( $(../providers/${PROVIDER}/list-machines.sh | wc) > 0 ))
do
    echo "Waiting for destruction ..."
    sleep 60
done
./create.sh