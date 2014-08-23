#!/bin/bash
#trap 'echo FAILED' ERR
cd $(dirname $0)
. ../../commands/common.sh
. ./do_common.sh
set -eu
image=${DO_BASE_IMAGE}
while getopts "F" OPTION
do
     case $OPTION in
         F)
             image=$(tugboat info_image -n $(template_name) | grep ID: | cut -d: -f2  | tr -d ' ' | tail -1)
             ;;
         ?)
             echo "-F for fast"
             exit
             ;;
     esac
done
shift $((OPTIND-1))

tugboat create --size=${DO_IMAGE_SIZE} --image=${image} --region=${DO_REGION}  --keys=${DO_KEYS} --private-networking  $1   >&2

while ! tugboat wait $1
do
    sleep 30
done
sleep 30
while ! tugboat ssh -c "true" $1
do
    sleep 60
done
$(pwd)/list-machines-by-ip.sh $1
