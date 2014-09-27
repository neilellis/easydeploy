#!/bin/bash -eux
set -e
cd $(dirname $0)
. ../../commands/common.sh
. ./do_common.sh

function filter() {
	while read -r line
	do
		mc=$(echo $line | cut -d' ' -f1)
		if echo $mc  | grep "$(mc_name)$" &> /dev/null && echo $mc | grep -v 'template-' &> /dev/null
		then
			echo "$line"
        fi
	done
}

function convert() {
	while read -r line
	do
		mc=$(echo $line | cut -d' ' -f1)
        ip=$(echo $line | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
        while cfcli removerecord $mc | grep -v "Unable"
        do
            echo "Cleaning up $mc records"
        done
        cfcli addrecord -t A $mc $ip ||  cfcli editrecord -t A $mc $ip
	done
}


$tugboat droplets | filter | convert

