#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eu
./image.sh
../providers/${PROVIDER}/scale.sh min





