#!/bin/bash -eux

. /home/easydeploy/bin/env.sh

#
if  [[ $DEPLOY_ENV == "prod" ]]  && [[ -f  /home/easydeploy/usr/etc/datadog-agent-image.txt ]]  && [[ -f  /home/easydeploy/usr/etc/datadog-api-key.txt ]]
then
    echo "Starting DataDog Agent"
    if ! grep "${HOST}-${IP}" < /etc/dd-agent/datadog.conf
    then
        echo "tags: environment:${DEPLOY_ENV}, component:${COMPONENT}, project:${PROJECT}" >> /etc/dd-agent/datadog.conf
        echo "hostname: ${HOST}-${IP}" >> /etc/dd-agent/datadog.conf
    fi

docker pull $(< /home/easydeploy/usr/etc/datadog-agent-image.txt)

    docker run -t -i --rm=true -P --privileged --name datadog -h `hostname` -v /var/easydeploy/share:/var/easydeploy/share -v /var/run/docker.sock:/var/run/docker.sock -v /proc/mounts:/host/proc/mounts:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e API_KEY=$(< /home/easydeploy/usr/etc/datadog-api-key.txt) $(< /home/easydeploy/usr/etc/datadog-agent-image.txt)

else
    echo "No DataDog config, so sleeping."
    sleep 86400
fi
