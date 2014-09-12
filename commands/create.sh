#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eu
./image.sh
./rebuild-machines.sh
./scale.sh min





