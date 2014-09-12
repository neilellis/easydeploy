#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eu
./update.sh
./scale.sh min
./wire.sh





