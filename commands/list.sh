#!/bin/sh

set -eu
cd $(dirname $0) &> /dev/null
../providers/${PROVIDER}/list-machines.sh





