#!/bin/bash -x

cd $(dirname $0) &> /dev/null
. common.sh
machines="$(../providers/${PROVIDER}/list-machines-by-ip.sh $(machineName) | tr '\n' ' ' | tr -s ' ')"
for machine in $machines
do
        ./deploy.sh $machine
        ssh  -o "StrictHostKeyChecking no" easyadmin@${machine} "sudo reboot"
done




