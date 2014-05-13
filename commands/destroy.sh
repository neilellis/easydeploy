#!/bin/sh
set -eu
cd $(dirname $0) &> /dev/null
. common.sh
export MACHINE_NAME=$(machineName)
set -eu

../providers/${PROVIDER}/scale.sh 0





