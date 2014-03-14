#!/bin/sh
set -eu
if ! which tugboat
then
    sudo gem install tugboat
fi
if tugboat info $1
then
    tugboat destroy -c $1
fi

