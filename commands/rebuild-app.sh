#!/bin/bash -eu

cd $(dirname $0) &> /dev/null
. common.sh

if [ -z "${USE_PARALLEL}" ]
then
    machines="$(../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tr '\n' ' ' | tr -s ' ')"
    for machine in $machines
    do
            ssh  -o "StrictHostKeyChecking no" easydeploy@${machine} "./bin/build.sh update"
            ssh  -o "StrictHostKeyChecking no" easyadmin@${machine} "supervisorctl restart all"
    done
else
   ../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | parallel --gnu -P 0 --bar --no-run-if-empty "ssh  -o 'StrictHostKeyChecking no' easydeploy@{} './bin/build.sh update'; ssh  -o 'StrictHostKeyChecking no' easyadmin@{} 'supervisorctl restart all'"
fi








