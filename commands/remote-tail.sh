#!/bin/bash
if ! which multitail
then
    echo "Please install multitail before running this command"
    exit -1
fi
trap 'echo FAILED' ERR
cd $(dirname $0) &> /dev/null
. common.sh
machines=$(../providers/${PROVIDER}/list-machines-by-ip.sh $(machineName) | tr '\n' ' ')
cmd="multitail "
for machine in $machines
do
    cmd="${cmd} -l 'ssh -o \"StrictHostKeyChecking no\" ${USERNAME}@${machine} \"tail -F /var/log/easydeploy/*\"'"
done

echo ${cmd}
bash -c "${cmd}"




