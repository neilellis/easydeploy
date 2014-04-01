#!/bin/sh
deploy_env=/var/easydeploy/share/.config/deploy_env
components=$(serf members -tag deploy_env=${deploy_env} |  tr -s ' ' | cut -d' ' -f4 | tr ',' '\n' | grep '^component=' | cut -d= -f2 | sort -u)

for c in $components
do
    serf members -tag deploy_env=${deploy_env} -tag component=${c}   | tr -s ' ' | cut -d' ' -f2 | cut -d: -f1 > /var/easydeploy/share/.config/dynamic/components/${c}.txt
    serf members -tag deploy_env=${deploy_env} -tag component=${c}   |  tr -s ',' ';' | tr -s ' ' |  tr ' ' ',' > /var/easydeploy/share/.config/dynamic/components/${c}.csv
done

serf members -tag deploy_env=${deploy_env}  | tr -s ' ' | cut -d' ' -f2 > /var/easydeploy/share/.config/dynamic/components/all.txt
serf members -tag deploy_env=${deploy_env} |  tr -s ',' ';' | tr -s ' ' |  tr ' ' ',' > /var/easydeploy/share/.config/dynamic/components/all.csv

