#!/bin/bash
function changed() {
    while read file
    do
        echo $file changed
        /home/easydeploy/bin/notify.sh $file changed
#        shutdown now
    done
}

fileschanged -r /etc /usr /bin /sbin /lib /lib64 /boot | changed