#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eux
./update.sh
./scale.sh min
while ! ./wire.sh
do
    ./remote.sh "sudo reboot"
    echo "Retrying to wire"
    sleep 60
done





