#!/bin/bash -eu
cd $(dirname $0)
. common.sh

for id in $(../providers/${PROVIDER}/list-machines-by-id.sh "^template-.*"| cut -d: -f2)
do
    tugboat destroy -c -i ${id} || echo "Couldn't destroy ${id}"
done

