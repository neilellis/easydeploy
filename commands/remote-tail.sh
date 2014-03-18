#!/bin/bash
if ! which multitail
then
    echo "Please install multitail before running this command"
    exit -1
fi
trap 'echo FAILED' ERR
if [ $# -eq 1 ]
then
    cd $(dirname $1)
    export ENV_FILE=$(pwd)/$1
    cd -
    source $ENV_FILE
    shift
fi
cd $(dirname $0) &> /dev/null
machines=$(../providers/${PROVIDER}/list-machines-by-ip.sh | tr '\n' ' ')
cmd="multitail "
for machine in $machines
do
    cmd="${cmd} -l 'ssh -o \"StrictHostKeyChecking no\" ${USERNAME}@${machine} \"tail -F /var/log/easydeploy/*\"'"
done

echo ${cmd}
bash -c "${cmd}"




