#!/bin/bash
#trap 'echo FAILED' ERR
cd $(dirname $0)
. ../../commands/common.sh
. ./do_common.sh

set -eux
image=${DO_BASE_IMAGE}


while getopts "F" OPTION
do
     case $OPTION in
         F)
             image=$($tugboat info_image -n $(template_name) | grep ID: | cut -d: -f2  | tr -d ' ' | tail -1)
             ;;
         ?)
             echo "-F for fast"
             exit
             ;;
     esac
done
shift $((OPTIND-1))

$tugboat create --size=${DO_IMAGE_SIZE} --image=${image} --region=${DO_REGION}  --keys=${DO_KEYS}  $1   >&2
sleep 60
id=$($(pwd)/list-machines-by-id.sh $1 | tail -1)
$tugboat wait -i $id
sleep 60
$tugboat ssh -c "true" -i $id
./do_to_cf.sh
$(pwd)/list-machines-by-ip.sh $1 | tail -1

