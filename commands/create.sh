#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eux
#./update.sh
./scale.sh min
./update.sh
./remote.sh "sudo reboot"
sleep 30
while ! ./wire.sh
do

    ./remote.sh "sudo reboot"
    echo "Retrying to wire"
    sleep 120
done





