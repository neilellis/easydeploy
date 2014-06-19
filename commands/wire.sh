#!/bin/bash
trap 'echo FAILED' ERR
cd $(dirname $0) &> /dev/null
. common.sh
profileMachines=$(../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tr '\n' ' ')
machines=$(../providers/${PROVIDER}/list-project-machines-by-ip.sh | tr '\n' ' ')

for profileMachine in $profileMachines
do
     ssh -o "StrictHostKeyChecking no" ${USERNAME}@${profileMachine} "serf join $machines"
done



