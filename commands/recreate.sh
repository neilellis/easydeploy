#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eux
./rebuild-machines.sh
while (( $(../providers/${PROVIDER}/list-machines.sh | grep "^$(mc_name):" | wc -l ) > 0 ))
do
    echo "Waiting for destruction ..."
    sleep 60
done
./create.sh