#!/bin/bash

cd $(dirname $0) &> /dev/null
. common.sh
machines=$(../providers/${PROVIDER}/list-machines-by-ip.sh $(machineName) | tr '\n' ' ')
for machine in $machines
do
    ./deploy.sh $machine
done




