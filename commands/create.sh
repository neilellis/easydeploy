#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eu
./update.sh
./scale.sh min
while ! ./wire.sh
do
    ./remote.sh "sudo reboot"
    echo "Retying to wire"
    sleep 60
done





