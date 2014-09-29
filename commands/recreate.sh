#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
set -eux
./rebuild-machines.sh
./scale.sh min
./remote.sh "sudo reboot"