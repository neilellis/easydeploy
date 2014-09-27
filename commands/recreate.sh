#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eux
./destroy.sh
sleep 60
./create.sh