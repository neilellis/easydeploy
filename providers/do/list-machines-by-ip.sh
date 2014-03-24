#!/bin/sh
set -e
cd $(dirname $0)
. ../../commands/common.sh

tugboat droplets | grep "$1 " |  cut -d":" -f2| tr -d ')' | cut -d, -f1 | tr -d ' '
