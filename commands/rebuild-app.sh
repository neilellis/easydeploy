#!/bin/bash -eu

cd $(dirname $0) &> /dev/null
. common.sh


if [ -z "${USE_PARALLEL}" ]
then
    machines="$(../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tr '\n' ' ' | tr -s ' ')"
    for machine in $machines
    do
            sync ${DIR}/*  ${USERNAME}@${machine}:~/project/
            ssh  -o "StrictHostKeyChecking no" easydeploy@${machine} "cd project; docker build . ;"
            ssh  -o "StrictHostKeyChecking no" easyadmin@${machine} "supervisorctl restart all"
    done
else
   ../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | parallel --gnu -P 0 --bar --no-run-if-empty "sync ${DIR}/*  ${USERNAME}@{}:~/project/; ssh  -o 'StrictHostKeyChecking no' easydeploy@{} 'cd project; docker build .'; ssh  -o 'StrictHostKeyChecking no' easyadmin@{} 'supervisorctl restart all'"
fi









