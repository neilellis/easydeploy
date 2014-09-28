#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eux
./destroy.sh
./create.sh