#!/bin/sh
set -e
cd $(dirname $0)
. ../../commands/common.sh

tugboat droplets | sed "s/, status.*//g"| sed "s/.ip//g" | tr -d ' '