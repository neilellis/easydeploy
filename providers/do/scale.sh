#!/bin/bash -x
#trap 'echo FAILED' ERR
cd $(dirname $0)

current=$(echo $(tugboat droplets | grep "^${MACHINE_NAME} " | wc -l))
export ids=( $(./list-machines-by-id.sh "^${MACHINE_NAME} " ) )
echo "Currently $current servers requested $1 servers running difference is $(($1 - $current))"

if [ $current -gt $1 ]
then
    seq 0 $(echo $current - $1 - 1 | bc)  | (while read i; do echo ${ids[$i]};done) | parallel "tugboat destroy -c -i {}"

elif [ $current -lt $1 ]
then
    for i in $(seq $current $(($1 - 1)) )
    do
        echo "Creating new ${MACHINE_NAME}"
        tugboat create --quiet --size=${DO_IMAGE_SIZE} --image=${DO_BASE_IMAGE} --region=${DO_REGION}  --keys=${DO_KEYS} --private-networking  $MACHINE_NAME
    done
else
    echo "Nothing to do."
fi
true
