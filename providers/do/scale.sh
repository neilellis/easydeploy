#!/bin/bash -eu
#trap 'echo FAILED' ERR
cd $(dirname $0)
. ../../commands/common.sh
. ./do_common.sh

current=$(echo $($tugboat droplets | grep "^${MACHINE_NAME} " | wc -l))
export ids=( $(./list-machines-by-id.sh "^${MACHINE_NAME} " ) )
echo "Currently $current servers requested $1 servers running difference is $(($1 - $current))"

if [ $current -gt $1 ]
then
    for i in $(seq 0 $(($current - $1 - 1)))
    do
        $tugboat destroy -c -i $ids[${i}] &
    done

elif [ $current -lt $1 ]
then
    for i in $(seq $current $(($1 - 1)) )
    do
        echo "Creating new ${MACHINE_NAME}"
        ../../commands/deploy-and-provision.sh
    done
else
    echo "Nothing to do."
fi
true
