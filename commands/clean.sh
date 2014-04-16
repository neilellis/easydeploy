#!/bin/sh
cd $(dirname $0)
common.sh

set -eux

for id in $(../providers/${PROVIDER}/list-machines-by-id.sh "^template-.*"| cut -d: -f2)
do
    tugboat destroy -i ${id} || echo "Couldn't destroy ${id}"
done

