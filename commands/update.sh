#!/bin/bash -eux

cd $(dirname $0) &> /dev/null
. common.sh

if [ -z "${USE_PARALLEL}" ]
then
    machines="$(../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tr '\n' ' ' | tr -s ' ')"
    echo "Updating $machines"
    for machine in $machines
    do
            ./deploy.sh $machine
    done
else
   ../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | parallel --gnu -P 0 --no-run-if-empty  "./deploy.sh {}"
fi









