#!/bin/sh
set -u
if ! which tugboat > /dev/null
then
   echo "Please install tugboat using 'gem install tugboat'"
fi
cd $(dirname $0)
. ../../commands/common.sh

MACHINE_NAME=$(machineName)
tugboat droplets | grep "${MACHINE_NAME} " |  cut -d":" -f2| tr -d ')' | cut -d, -f1 | tr -d ' '
