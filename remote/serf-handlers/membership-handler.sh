#!/bin/bash


/ezbin/update_dns.sh


if [[ $(cat /var/easydeploy/share/.config/deploy_env) == ${SERF_TAG_DEPLOY_ENV} ]]
then
    serf members -tag deploy_env=${SERF_TAG_DEPLOY_ENV} -tag component=${SERF_TAG_COMPONENT}   | tr -s ' ' | cut -d' ' -f2 | cut -d: -f1  > /var/easydeploy/share/.config/discovery/${SERF_TAG_COMPONENT}.txt
    serf members -tag deploy_env=${SERF_TAG_DEPLOY_ENV} -tag component=${SERF_TAG_COMPONENT}   |  tr -s ',' ';' | tr -s ' ' |  tr ' ' ',' > /var/easydeploy/share/.config/discovery/${SERF_TAG_COMPONENT}.csv
    serf members -tag deploy_env=${SERF_TAG_DEPLOY_ENV}  | tr -s ' ' | cut -d' ' -f2 | cut -d: -f1 > /var/easydeploy/share/.config/discovery/all.txt
    serf members -tag deploy_env=${SERF_TAG_DEPLOY_ENV} |  tr -s ',' ';' | tr -s ' ' |  tr ' ' ',' > /var/easydeploy/share/.config/discovery/all.csv
fi


if [ -f /home/easydeploy/deployment/membership_handler.sh ]
then
    cd  /home/easydeploy/deployment
    bash /home/easydeploy/deployment/membership_handler.sh
    cd -
fi
exit 0
