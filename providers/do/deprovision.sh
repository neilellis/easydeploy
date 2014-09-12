#!/bin/bash -eu
cd $(dirname $0)
. ../../commands/common.sh
. ./do_common.sh

set -eux

for id in $(./list-machines-by-id.sh "^${1} ")
do
    tugboat destroy -c -i ${id} || echo "Couldn't destroy ${id}"
done

./do_to_cf.sh


