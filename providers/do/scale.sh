#!/bin/sh
#trap 'echo FAILED' ERR

current=$(echo $(tugboat droplets | grep "^${MACHINE_NAME} " | wc -l))
echo "Currently $current servers requested $1 servers running difference is $(($1 - $current))"

if [ $current -gt $1 ]
then
    for i in $(seq 0 $(echo $current - $1 | bc))
    do
        echo $i | tugboat destroy -c -n $MACHINE_NAME
    done
else
    for i in $(seq $current $1)
    do
    tugboat create --quiet --size=${DO_IMAGE_SIZE} --image=${DO_BASE_IMAGE} --region=${DO_REGION}  --keys=${DO_KEYS} --private-networking  $MACHINE_NAME
    done
fi
