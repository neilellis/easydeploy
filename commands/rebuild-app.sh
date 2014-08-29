#!/bin/bash -eu

cd $(dirname $0) &> /dev/null
. common.sh



if [ -z "${USE_PARALLEL}" ]
then
    machines="$(../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tr '\n' ' ' | tr -s ' ')"
    for machine in $machines
    do
            sync ${DIR}/*  easydeploy@${machine}:~/project/
            ssh  -o "StrictHostKeyChecking no" easyadmin@${machine} '/usr/bin/supervisorctl restart $(cat /var/easydeploy/share/.config/component):'
            sleep ${1:-120}
    done
else
   ../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | parallel --gnu -P 0  "set -eux; sync ${DIR}/*  easydeploy@{}:~/project/;  ssh  -o 'StrictHostKeyChecking no' easyadmin@{} '/usr/bin/supervisorctl restart $(cat /var/easydeploy/share/.config/component):' "
fi










