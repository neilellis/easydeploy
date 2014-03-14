#!/bin/sh
if [ $# -eq 1 ]
then
cd $(dirname $1)
export ENV_FILE=$(pwd)/$1
cd -
source $ENV_FILE
fi
set -eu
cd $(dirname $0) &> /dev/null
./build-image.sh
./providers/${PROVIDER}/rebuild-machines.sh





