#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
export MACHINE_NAME=$(mc_name)
set -eu

../providers/${PROVIDER}/scale.sh 0





