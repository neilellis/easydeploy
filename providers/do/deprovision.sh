#!/bin/sh
cd $(dirname $0)
. ../../commands/common.sh

set -eux

for id in $(./list-machines-by-id.sh "^${1} ")
do
    tugboat destroy -c -i ${id} || echo "Couldn't destroy ${id}"
done

