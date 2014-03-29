#!/bin/sh
set -eux
cd $(dirname $0)
DIR=$(pwd)


export COMPONENT=$1
shift
export DEPLOY_ENV=$1
shift
export GIT_BRANCH=$1
shift
export APP_ARGS="$@"
export EASYDEPLOY_PORTS=80
export EASYDEPLOY_UPDATE_CRON="0 4 * * *"
export EASYDEPLOY_PACKAGES=
export EASYDEPLOY_STATE="stateful"
export EASYDEPLOY_PROCESS_NUMBER=1
export EASYDEPLOY_EXTERNAL_PORTS=
export EASYDEPLOY_UPDATE_CRON=none
export EASYDEPLOY_HOST_IP=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

. /home/easydeploy/deployment/ed.sh


#Create main directories
sudo [ -d /home/easydeploy/bin ] || mkdir /home/easydeploy/bin
sudo [ -d /var/log/easydeploy ] || mkdir /var/log/easydeploy
sudo [ -d /var/easydeploy ] || mkdir /var/easydeploy
sudo [ -d /var/easydeploy/share ] || mkdir /var/easydeploy/share
sudo [ -d /var/easydeploy/share/sync ] || mkdir /var/easydeploy/share/sync
sudo [ -d /var/easydeploy/share/sync/global ] || mkdir /var/easydeploy/share/sync/global
sudo [ -d /var/easydeploy/share/sync/component ] || mkdir /var/easydeploy/share/sync/component
sudo [ -d /var/easydeploy/share/sync/env ] || mkdir /var/easydeploy/share/sync/env
sudo [ -d /var/easydeploy/share/.config/ ] || mkdir /var/easydeploy/share/.config/

#store useful info for scripts
echo ${EASYDEPLOY_STATE} > /var/easydeploy/share/.config/edstate
echo ${APP_ARGS} > /var/easydeploy/share/.config/app_args
echo ${COMPONENT} > /var/easydeploy/share/.config/component
echo ${GIT_BRANCH} > /var/easydeploy/share/.config/branch
echo ${DEPLOY_ENV} > /var/easydeploy/share/.config/deploy_env
sudo chown easydeploy:easydeploy /var/easydeploy/share

if [ ! -z ${EASYDEPLOY_PACKAGES} ]
then
    sudo apt-get install -y ${EASYDEPLOY_PACKAGES}
fi

#Security
sudo apt-get install -y denyhosts

#Sync
sudo apt-get install -y  rhash
sudo add-apt-repository -y ppa:tuxpoldo/btsync
sudo apt-get update
echo "n" | sudo apt-get install -y btsync
export EASYDEPLOY_GLOBAL_SYNC_SECRET="$(cat /home/easydeploy/.ssh/id_rsa | sed -e 's/0/1/g' | rhash --sha512 - | cut -c1-64 )"
export EASYDEPLOY_COMPONENT_SYNC_SECRET="$(cat /home/easydeploy/.ssh/id_rsa /var/easydeploy/share/.config/component /var/easydeploy/share/.config/deploy_env | rhash --sha512 - | cut -c1-64)"
export EASYDEPLOY_ENV_SYNC_SECRET="$(cat /home/easydeploy/.ssh/id_rsa /var/easydeploy/share/.config/deploy_env | rhash --sha512 - | cut -c1-64)"
sudo cat >  /etc/btsync/default.conf <<EOF
//!/usr/lib/btsync/btsync-daemon --config
//
// in this profile, btsync will run as my user ID
// DAEMON_UID=easydeploy
//
{
    "device_name": "$EASYDEPLOY_HOST_IP",
    "listening_port": 9595,
    "check_for_updates": false,
    "storage_path":"/var/easydeploy/share/sync",
    "use_upnp": false,
    "download_limit": 0,
    "upload_limit": 0,
    "shared_folders": [
        {
            "secret": "$EASYDEPLOY_GLOBAL_SYNC_SECRET",
            "dir": "/var/easydeploy/share/sync/global",
            "use_relay_server": true,
            "use_tracker": true,
            "use_dht": false,
            "search_lan": true,
            "use_sync_trash": true

        },
        {
            "secret": "$EASYDEPLOY_COMPONENT_SYNC_SECRET",
            "dir": "/var/easydeploy/share/sync/component",
            "use_relay_server": true,
            "use_tracker": true,
            "use_dht": false,
            "search_lan": true,
            "use_sync_trash": true

        },
        {
            "secret": "$EASYDEPLOY_ENV_SYNC_SECRET",
            "dir": "/var/easydeploy/share/sync/env",
            "use_relay_server": true,
            "use_tracker": true,
            "use_dht": false,
            "search_lan": true,
            "use_sync_trash": true

        }
    ]
}
EOF
echo 'AUTOSTART="all"' > /etc/default/btsync
sudo chown -R easydeploy:easydeploy /var/easydeploy/share/sync
sudo chown -R easydeploy:easydeploy /etc/btsync/default.conf
sudo chmod 600 /etc/btsync/default.conf
sudo service btsync start


sudo apt-get install -y unzip
wget https://dl.bintray.com/mitchellh/serf/0.5.0_linux_amd64.zip
unzip 0.5.0_linux_amd64.zip
sudo mv serf /usr/local/bin
[ -d /etc/serf ] || sudo mkdir /etc/serf
sudo mv -f serf-event-handler.sh /etc/serf/event-handler.sh
[ -d /etc/serf ] || sudo mkdir /etc/serf
[ -d /etc/serf/handlers ] && sudo rm -rf /etc/serf/handlers
sudo mv -f serf-handlers /etc/serf/handlers


sudo apt-get install -y supervisor timelimit
sudo [ -d /home/easydeploy/modules ] && rm -rf /home/easydeploy/modules
sudo cp -r modules /home/easydeploy

sudo chown easydeploy:easydeploy /var/log/easydeploy
sudo chown easydeploy:easydeploy /var/easydeploy


sudo [ -d /home/easydeploy/template ] || mkdir /home/easydeploy/template
[ -f machines.txt ] && mv -f machines.txt  /var/easydeploy/share/.config/machines.txt
sudo mv -f run.sh update.sh gitpoll.sh build.sh /home/easydeploy/bin
sudo chmod 755 /home/easydeploy/bin/*
sudo /bin/bash <<EOF
export COMPONENT=${COMPONENT}
export EASYDEPLOY_HOST_IP=$EASYDEPLOY_HOST_IP
export DEPLOY_ENV=$DEPLOY_ENV
export EASYDEPLOY_PROCESS_NUMBER=${EASYDEPLOY_PROCESS_NUMBER}
envsubst < template-run.conf  > /etc/supervisor/conf.d/run.conf
EOF

if [[ ${EASYDEPLOY_STATE} == "stateless" ]]
then
    touch /home/easydeploy/.stateless-service
    touch /var/easydeploy/share/.stateless-service
fi


sudo cp template-run.conf /home/easydeploy/template/

if [ ${EASYDEPLOY_UPDATE_CRON} != "none" ]
then
    sudo crontab <<EOF2
${EASYDEPLOY_UPDATE_CRON} /home/easydeploy/bin/update.sh "$[ ( $RANDOM % 3600 )  + 1 ]s" &> /va/log/easydeploy/update.log
EOF2
fi

cd
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sudo apt-get update  -y
sudo apt-get -y install linux-image-extra-`uname -r`
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get -y update
sudo apt-get install -y lxc-docker


#Pre installation custom tasks
[ -f /home/easydeploy/deployment/pre-install.sh ] && sudo bash /home/easydeploy/deployment/pre-install.sh


#sudo addgroup worker docker
sudo addgroup easydeploy docker
sudo chmod a+rwx /var/run/docker.sock
sudo chown -R easydeploy:easydeploy /home/easydeploy/
cd /home/easydeploy/deployment
service docker start || true
sudo su easydeploy -c "/home/easydeploy/bin/build.sh"
sudo chmod a+rwx /var/run/docker.sock
cd

sudo ufw allow 22   #ssh
sudo ufw allow 7946 #serf
sudo ufw allow 9595 #btsync

for port in ${EASYDEPLOY_PORTS} ${EASYDEPLOY_EXTERNAL_PORTS}
do
sudo ufw allow ${port}
done
yes | sudo ufw enable
sudo service supervisor stop || true
sudo docker kill $(docker ps -q) || true
sudo timelimit -t 30 -T 5 service docker stop
[ -e  /tmp/supervisor.sock ] && sudo unlink /tmp/supervisor.sock
[ -e  /var/run/supervisor.sock  ] && sudo unlink /var/run/supervisor.sock
sleep 10
sudo killall docker || true
sudo service docker start
sudo service supervisor start
sudo supervisorctl restart all
[ -f  /home/easydeploy/deployment/post-install.sh ] && sudo bash /home/easydeploy/deployment/post-install.sh
[ -f  /home/easydeploy/deployment/post-install-userland.sh ] && sudo su  easydeploy "cd; bash  /home/easydeploy/deployment/post-install-userland.sh"

function joinSerf() {
    while read ip
    do
       if timelimit -t 2 -T 1 -s 2 serf join $ip
       then
            break
       fi

    done

}

if [ -f /var/easydeploy/share/.config/machines.txt ]
then
    sleep 10
    echo "Attempting to join the serf cluster, sending join request to all machines."
#    cat /var/easydeploy/share/.config/machines.txt | cut -d: -f2  | joinSerf
fi

exit 0
