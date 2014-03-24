#!/bin/sh
set -e
cd $(dirname $0)
. ../../commands/common.sh

tugboat droplets | grep "$(machineName) "
