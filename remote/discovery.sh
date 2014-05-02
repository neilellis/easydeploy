#!/bin/bash -eu
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

mkdir -p /var/easydeploy/share/.config/sync/discovery/ || :
mkdir -p /var/easydeploy/share/.config/discovery/ || :
ip=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

function joinSerf() {
    while read i
    do
       #If the machine is not available don't hang around, move on quickly
       timelimit -t 2 -T 1 -s 2 serf join $i || :
    done
}

function joinConsul() {
    while read i
    do
       #If the machine is not available don't hang around, move on quickly
       timelimit -t 2 -T 1 -s 2 consul join $i || :
    done
}

if  ! serf members &> /dev/null
then
    echo "Serf agent not running"
    sleep 15
    exit -1
fi

if [ -f /var/easydeploy/share/.config/sync/discovery/all.txt ]
then
    #Bootstrap from a bit torrent sync'd file
    echo "Attempting to join with other serf nodes, sending join request to all previously known machines in the environment."
    #We ask every node, because we don't want split brains, unless under
    #a zombie attack
    cat /var/easydeploy/share/.config/sync/discovery/all.txt |  joinSerf
fi

#Only bootstrap if we haven't already connected to other machines
if (( $(serf members | wc -l) < 2 ))
then

        sleep 10
        echo "Attempting to join with other serf nodes the hard way, sending join request to all known machines."
        #We ask every node, because we don't want split brains, unless under
        #a zombie attack
        #Try the known machines
        cat /var/easydeploy/share/.config/machines.txt | cut -d: -f2 |  joinSerf
        sleep 15
        touch /var/easydeploy/share/.config/sync/discovery/all.txt
fi


while true
do

    #The name of the deployment env, e.g. dev,prod,test
    deploy_env=$(cat /var/easydeploy/share/.config/deploy_env)
    #A list of all the difference components in the env, like db,api,redis etc.
    components=$(serf members -tag deploy_env=${deploy_env} |  tr -s ' ' | cut -d' ' -f4 | tr ',' '\n' | grep '^component=' | cut -d= -f2 | sort -u)


    #Create a txt and csv file for all the components in the env
    for c in $components
    do
        serf members -tag deploy_env=${deploy_env} -tag component=${c}   | tr -s ' ' | cut -d' ' -f2 | cut -d: -f1 | sort -u  > /var/easydeploy/share/.config/discovery/${c}.txt
        serf members -tag deploy_env=${deploy_env} -tag component=${c}   |  tr -s ',' ';' | tr -s ' ' |  tr ' ' ',' | sort -u > /var/easydeploy/share/.config/discovery/${c}.csv

        if [ $c == "logstash" ]
        then
            logstash=$(cat /var/easydeploy/share/.config/discovery/${c}.txt| tail -1)

            cat > /etc/logstash.conf  <<EOF
    input {
      file {
      add_field => {
        component => "$(cat /var/easydeploy/share/.config/component)"
        env =>  "$(cat /var/easydeploy/share/.config/deploy_env)"
        host => "${ip}"

    }

    type => "syslog"
        path => [ "/var/log/messages", "/var/log/syslog", "/var/log/*.log",  "/var/log/easydeploy/*.log" ]
      }
    }

    output {
     tcp {  host =>"${logstash}" port => 7007 codec => "json" mode => "client"}
    }

EOF
        supervisorctl restart logstash
        fi
    done

    #Create a txt and csv file containing all the machines in the env
    serf members -tag deploy_env=${deploy_env}  | tr -s ' ' | cut -d' ' -f2  | cut -d: -f1 > /var/easydeploy/share/.config/discovery/all.txt
    serf members -tag deploy_env=${deploy_env} |  tr -s ',' ';' | tr -s ' ' |  tr ' ' ',' > /var/easydeploy/share/.config/discovery/all.csv

    cat /var/easydeploy/share/.config/discovery/all.txt | joinConsul

    cat  /var/easydeploy/share/.config/discovery/all.txt /var/easydeploy/share/.config/sync/discovery/all.txt  | sort -u > /var/easydeploy/share/.config/sync/discovery/all.txt

    supervisorctl start gitpoll || :
    supervisorctl start logstash-ship || :
    supervisorctl start "$(cat /var/easydeploy/share/.config/component):" || :

    sleep 3600
done