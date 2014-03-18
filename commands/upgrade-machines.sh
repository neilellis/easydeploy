#!/bin/sh
if [ $# -eq 1 ]
then
export ENV_FILE=$1
source $ENV_FILE
fi
set -eu
cd $(dirname $0) &> /dev/null
./build-image.sh
sleep 60
../providers/${PROVIDER}/rebuild-machines.sh





