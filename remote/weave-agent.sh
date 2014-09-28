#!/bin/bash -eux



first=true
while :
do
    subnet=$(/ezbin/obtain_subnet_address.sh)
    if [[ -z $subnet ]]
    then
        echo "Could not obtain subnet address."
        sleep 30
    else
        if [[ ! -f /var/easydeploy/share/.config/weave_subnet ]]  || [[ $(</var/easydeploy/share/.config/weave_subnet) != $subnet ]] || [[ -n $first ]]
        then
            weave stop
            echo $subnet > /var/easydeploy/share/.config/weave_subnet
            members=$(serf members  -tag "weave_subnet=10.*" | tr -s ' ' | cut -d' ' -f2 | cut -d: -f1 | sort -u | tr '\n' ' ')
            weave launch ${subnet}.1/8 -password $(cat /var/easydeploy/share/.config/serf_key) ${members}
            serf tags -set weave_subnet=${subnet}
            weave expose ${subnet}.2/8
            first=
        fi
    sleep 600
    fi
done