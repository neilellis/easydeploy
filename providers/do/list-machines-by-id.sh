#!/bin/sh
set -e
cd $(dirname $0)
. ../../commands/common.sh

tugboat droplets | grep "$1" | cut -d: -f5 | cut -d")" -f1| tr -d ' '
