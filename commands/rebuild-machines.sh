#!/bin/sh

set -eu
cd $(dirname $0) &> /dev/null
../providers/${PROVIDER}/rebuild-machines.sh




