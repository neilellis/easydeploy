#Usage:
  #tugboat snapshot SNAPSHOT_NAME FUZZY_NAME [OPTIONS]
#
#Options:
  #-i, [--id=ID]      # The ID of the droplet.
  #-n, [--name=NAME]  # The exact name of the droplet
#


#!/bin/sh
trap 'echo FAILED' ERR

set -eu
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
if tugboat info_image $2
then
    tugboat destroy_image -c $2
fi

tugboat ssh --ssh-user=${USERNAME} -q -c "poweroff" $1
tugboat wait -s off $1
sleep 5
tugboat snapshot $2 $1
tugboat wait $1
tugboat info_image $2 | grep "ID:" | cut -d':' -f2 | tr -d ' '
