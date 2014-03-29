#!/bin/sh
#trap 'echo FAILED' ERR

set -ex
tugboat create --quiet --size=${DO_IMAGE_SIZE} --image=${DO_BASE_IMAGE} --region=${DO_REGION}  --keys=${DO_KEYS} --private-networking  $1

while ! tugboat wait $1
do
    sleep 30
done
sleep 30
while ! tugboat ssh -c "true" $1
do
    sleep 60
done
cd $(dirname $0)
. ../../commands/common.sh
$(pwd)/list-machines-by-ip.sh $1
