#!/bin/bash

. /home/easydeploy/bin/env.sh

function changed() {
    while read file
    do
        echo $file changed
        /home/easydeploy/bin/notify.sh ":cop:" $file changed
#        shutdown now
    done
}

fileschanged -r /etc /usr /bin /sbin /lib /lib64 /boot | changed