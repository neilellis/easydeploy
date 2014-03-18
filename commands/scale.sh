#!/bin/sh
if [ $# -eq 2 ]
then
export ENV_FILE=$1
source $ENV_FILE
shift
fi
set -eu
cd $(dirname $0) &> /dev/null
../providers/${PROVIDER}/scale.sh $1





