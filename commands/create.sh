#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eux
#./update.sh
./scale.sh min
./rebuild-app.sh
while ! ./wire.sh
do

    echo "Retrying to wire"
    sleep 60
done





