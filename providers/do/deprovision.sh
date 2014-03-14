#!/bin/sh
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

if tugboat info $1
then
    tugboat destroy -c $1
fi

