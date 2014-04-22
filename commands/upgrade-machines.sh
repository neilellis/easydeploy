#!/bin/bash
set -eu
cd $(dirname $0) &> /dev/null
./image.sh $@
sleep 60
../providers/${PROVIDER}/rebuild-machines.sh





