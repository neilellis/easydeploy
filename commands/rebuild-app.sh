#!/bin/bash -eu

cd $(dirname $0) &> /dev/null
. common.sh


if [ -z "${USE_PARALLEL}" ]
then
    machines="$(../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tr '\n' ' ' | tr -s ' ')"
    for machine in $machines
    do
            sync ${DIR}/*  easydeploy@${machine}:~/project/
            ssh  -o "StrictHostKeyChecking no" ${USERNAME}@${machine} "sudo chown -R /home/easydeploy/project easydeploy:easydeploy"
            ssh  -o "StrictHostKeyChecking no" easydeploy@${machine} "cd project; docker build . ;"
            ssh  -o "StrictHostKeyChecking no" easyadmin@${machine} "supervisorctl restart all"
    done
else
   ../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | parallel --gnu -P 0  "sync ${DIR}/*  ${USERNAME}@{}:~/project/; ssh  -o 'StrictHostKeyChecking no' ${USERNAME}@{} 'sudo chown -R /home/easydeploy/project easydeploy:easydeploy';ssh  -o 'StrictHostKeyChecking no' easydeploy@{} 'cd project; docker build .'; ssh  -o 'StrictHostKeyChecking no' easyadmin@{} 'supervisorctl restart ${COMPONENT}:'"
fi









