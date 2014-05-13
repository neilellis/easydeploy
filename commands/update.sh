#!/bin/bash -eu

cd $(dirname $0) &> /dev/null
. common.sh

if [ -z "${USE_PARALLEL}" ]
then
    machines="$(../providers/${PROVIDER}/list-machines-by-ip.sh $(machineName) | tr '\n' ' ' | tr -s ' ')"
    for machine in $machines
    do
            ./deploy.sh $machine
            ssh  -o "StrictHostKeyChecking no" easyadmin@${machine} "sudo reboot"
    done
else
   ../providers/${PROVIDER}/list-machines-by-ip.sh $(machineName) | parallel --gnu -P 0 --bar --no-run-if-empty  "./deploy.sh {} ; ssh  -o 'StrictHostKeyChecking no' easyadmin@{} 'sudo reboot'"
fi









