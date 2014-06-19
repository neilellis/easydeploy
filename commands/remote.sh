#!/bin/bash
cd $(dirname $0) &> /dev/null
. common.sh
machines=$(../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tr '\n' ' ')
for machine in $machines
do
    echo "$machine: $@"
    ssh -o "StrictHostKeyChecking no" easyadmin@${machine} "$@"
done




