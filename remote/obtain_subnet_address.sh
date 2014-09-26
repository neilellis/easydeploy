#!/bin/bash -eux

while [[ ! -f /var/easydeploy/share/.config/ip ]] || [[ -z $(</var/easydeploy/share/.config/ip) ]]
do
    echo "Waiting for IP address ..."  >&2
    sleep 10
done

host_ip=$(</var/easydeploy/share/.config/ip)

if [ -f ~/.consul_subnet_session ] && [[ -n $(<~/.consul_subnet_session) ]] && [[ $(curl "localhost:8500/v1/session/info/$(< ~/.consul_subnet_session)") != null ]]
then
    session=$(< ~/.consul_subnet_session)
else
    session=$(curl -s -X PUT http://localhost:8500/v1/session/create?raw | jq -r .ID)
fi

echo $session > ~/.consul_subnet_session

if [[ -z $session ]]
then
    exit -1
fi

#Can we re-use the last subnet we got for this machine?
#If so use it.
if curl -s -X PUT -d $host_ip http://localhost:8500/v1/kv/subnets/$(<~/.last_subnet_obtained)?acquire=$session | grep true >&2
then
    cat ~/.last_subnet_obtained
    exit 0
fi

#We're going to have to find one now
#Random numbers are used to
for i in $(seq 10 250)
do
   for j in $(seq 10 250)
   do
        sessionCheck=$(curl "http://localhost:8500/v1/session/info/${session}")

        if [[ ${sessionCheck} == null ]] || [[ ${sessionCheck} == "No cluster leader" ]]
        then
            exit -1
        fi

        ip="10.${i}.${j}"

        curl -s -X PUT -d "" http://localhost:8500/v1/kv/subnets/${ip}?release=$session >&2 || :
        if curl -s -X PUT -d $host_ip http://localhost:8500/v1/kv/subnets/${ip}?acquire=$session | grep true >&2
        then
            echo $ip > ~/.last_subnet_obtained
            echo $ip
            exit 0
        fi
    done
done