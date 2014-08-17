#[[ $DEPLOY_ENV == "prod" ]]  &&
if  [[ -f  /home/easydeploy/usr/etc/datadog-agent-image.txt ]]  && [[ -f  /home/easydeploy/usr/etc/datadog-api-key.txt ]]
then
    echo "Starting DataDog Agent"
    if ! grep "${HOST}-${IP}" < /etc/dd-agent/datadog.conf
    then
        echo "tags: environment:${DEPLOY_ENV}, component:${COMPONENT}, project:${PROJECT}" >> /etc/dd-agent/datadog.conf
        echo "hostname: ${HOST}-${IP}" >> /etc/dd-agent/datadog.conf
    fi

    DD_API_KEY=$(< /home/easydeploy/usr/etc/datadog-api-key.txt) bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"

    docker run -d --privileged --name datadog -h `hostname` -v /var/easydeploy/share:/var/easydeploy/share -v /var/run/docker.sock:/var/run/docker.sock -v /proc/mounts:/host/proc/mounts:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e API_KEY=$(< /home/easydeploy/usr/etc/datadog-api-key.txt) $(< /home/easydeploy/usr/etc/datadog-agent-image.txt)

else
    echo "No DataDog config, so sleeping."
    sleep 86400
fi
