#!/bin/bash -x
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

cd /home/easydeploy/deployment
export EASYDEPLOY_HOST_IP=$(</var/easydeploy/share/.config/ip)

. ./ed.sh
component=$(cat /var/easydeploy/share/.config/component)
deploy_env=$(cat /var/easydeploy/share/.config/deploy_env)
if [[  "$deploy_env" == "prod" ]] ||  [[  "$deploy_env" == "alt" ]]
then
    echo "Not polling in a prod environment"
    sleep 36000
    exit 0
fi

function  build() {
    if su easydeploy -c "/home/easydeploy/bin/build.sh 2>&1 | tee /tmp/build.out"
    then
               /home/easydeploy/bin/restart-component.sh && echo "Component restarted"
    else
                /home/easydeploy/bin/notify.sh ":thumbsdown:" "Build of $component failed: $(cat /tmp/build.out | tail -10)"
            echo "Docker build failed, no redeploy attempted."
   fi
}

while true
do
    if ! test $(docker images -q ${component} )  && [ ! -f /tmp/.install-in-progress ]
    then
        /home/easydeploy/bin/notify.sh ":grey_question:" "No docker image for $component so rebuilding."
        build
    fi
    su  easydeploy -c "git fetch &> .build_log.txt"
    if  [ -s .build_log.txt ]  && [ ! -f /tmp/.install-in-progress ]
    then
       su easydeploy -c "rm Dockerfile; git pull"
       build
    else
        sleep 120
    fi
    [ -e .build_log.txt ] && rm .build_log.txt
done