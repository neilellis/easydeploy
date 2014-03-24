#!/bin/sh
set -eu
cd $(dirname $0) &> /dev/null
./build-image.sh
sleep 60
../providers/${PROVIDER}/rebuild-machines.sh





