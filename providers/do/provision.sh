#!/bin/sh
trap 'echo FAILED' ERR

set -eux
if ! which tugboat
then
    sudo gem install tugboat
fi
#Usage:
  #tugboat create NAME
#
#Options:
  #-s, [--size=N]              # The size_id of the droplet
  #-i, [--image=N]             # The image_id of the droplet
  #-r, [--region=N]            # The region_id of the droplet
  #-k, [--keys=KEYS]           # A comma separated list of SSH key ids to add to the droplet
  #-p, [--private-networking]  # Enable private networking on the droplet

if tugboat info $1
then
    tugboat destroy -c $1
fi

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
tugboat info $1 | grep "IP:" | cut -d':' -f2 | tr -d ' '
