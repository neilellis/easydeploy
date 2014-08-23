#!/bin/bash -eu
cd $(dirname $0)
. ../../commands/common.sh
. ./do_common.sh

tugboat droplets | grep "$1 " |  cut -d":" -f2| tr -d ')' | cut -d, -f1 | tr -d ' '
