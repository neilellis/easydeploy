#!/bin/bash

error() {
    echo "**** EASYDEPLOY-COMPONENT-INSTALL-FAILED ****"
   sourcefile=$1
   lineno=$2
   code=$3
   echo "$1:$2" $3
   set +e
   exit $3
}

trap 'error "${BASH_SOURCE}" "${LINENO}" "$?"' ERR


set -eux
cd $(dirname $0)
DIR=$(pwd)


echo "Setting defaults"
export COMPONENT=$1
shift
export DEPLOY_ENV=$1
shift
export GIT_BRANCH=$1
shift
export PROJECT=$1
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

#Stay safe use the latest
sudo apt-get update
sudo apt-get -y upgrade

echo "Creating directories"
sudo [ -d /home/easydeploy/bin ] || mkdir /home/easydeploy/bin
sudo [ -d /home/easydeploy/usr/bin ] || mkdir -p /home/easydeploy/usr/bin
sudo [ -d /var/log/easydeploy ] || mkdir /var/log/easydeploy
sudo [ -d /var/easydeploy ] || mkdir /var/easydeploy
sudo [ -d /var/easydeploy/.install ] || mkdir /var/easydeploy/.install
sudo [ -d /var/easydeploy/share ] || mkdir /var/easydeploy/share
sudo [ -d /var/easydeploy/share/tmp ] || mkdir /var/easydeploy/share/tmp
sudo [ -d /var/easydeploy/share/tmp/hourly ] || mkdir /var/easydeploy/share/tmp/hourly
sudo [ -d /var/easydeploy/share/tmp/daily ] || mkdir /var/easydeploy/share/tmp/daily
sudo [ -d /var/easydeploy/share/tmp/monthly ] || mkdir /var/easydeploy/share/tmp/monthly
sudo [ -d /var/easydeploy/share/sync ] || mkdir /var/easydeploy/share/sync
sudo [ -d /var/easydeploy/share/sync/global ] || mkdir /var/easydeploy/share/sync/global
sudo [ -d /var/easydeploy/share/sync/discovery ] || mkdir /var/easydeploy/share/sync/discovery
sudo [ -d /var/easydeploy/share/sync/env ] || mkdir /var/easydeploy/share/sync/env
sudo [ -d /var/easydeploy/share/.config/ ] || mkdir /var/easydeploy/share/.config/
sudo [ -d /var/easydeploy/share/.config/sync/discovery ] || mkdir -p /var/easydeploy/share/.config/sync/discovery

sudo cp -f run.sh  serf-agent.sh update.sh gitpoll.sh build.sh discovery.sh notify.sh check_for_restart.sh intrusion.sh /home/easydeploy/bin
[ -d user-scripts ] && sudo cp -rf user-scripts/*  /home/easydeploy/usr/bin/
sudo chmod 755 /home/easydeploy/bin/*
sudo chmod 755 /home/easydeploy/usr/bin/* ||:


echo "Setting up deployment project"
sudo su - easydeploy <<EOF
set -eux
cd /home/easydeploy
chmod 600 ~/.ssh/*
chmod 700 ~/.ssh
ssh -o StrictHostKeyChecking=no git@${GIT_URL_HOST}  /bin/bash  &> /dev/null</dev/null  || true
git clone git@${GIT_URL_HOST}:${GIT_URL_USER}/easydeploy-${COMPONENT}.git
cd easydeploy-${COMPONENT}
git checkout ${GIT_BRANCH}
cd -
ln -s /home/easydeploy/easydeploy-${COMPONENT}/ /home/easydeploy/deployment
cp -f ~/.ssh/id_rsa  /home/easydeploy/deployment/id_rsa
cp -f ~/.ssh/id_rsa.pub  /home/easydeploy/deployment/id_rsa.pub
EOF


echo "Reading config"
. /home/easydeploy/deployment/ed.sh



#store useful info for scripts
echo "Saving config"
echo ${EASYDEPLOY_STATE} > /var/easydeploy/share/.config/edstate
echo ${APP_ARGS} > /var/easydeploy/share/.config/app_args
echo ${COMPONENT} > /var/easydeploy/share/.config/component
echo ${GIT_BRANCH} > /var/easydeploy/share/.config/branch
echo ${DEPLOY_ENV} > /var/easydeploy/share/.config/deploy_env
echo ${PROJECT} > /var/easydeploy/share/.config/project
cp serf_key  /var/easydeploy/share/.config/serf_key
sudo chown easydeploy:easydeploy /var/easydeploy/share

[ -f machines.txt ] && cp -f machines.txt  /var/easydeploy/share/.config/machines.txt


#Install additional host packages, try to avoid that and keep them in
#the Dockerfile where possible.
if [ ! -z ${EASYDEPLOY_PACKAGES} ]
then
    echo "Installing custom packages"
    sudo apt-get install -y ${EASYDEPLOY_PACKAGES}
fi


#Sync between nodes using btsync
echo "Installing Bit Torrent sync"
if [ ! -f /var/easydeploy/.install/btsync ]
then
sudo apt-get install -y  rhash
sudo add-apt-repository -y ppa:tuxpoldo/btsync
sudo apt-get update
echo "n" | sudo apt-get install -y btsync
export EASYDEPLOY_GLOBAL_SYNC_SECRET="$(cat /home/easydeploy/.ssh/id_rsa | sed -e 's/0/1/g' | rhash --sha512 - | cut -c1-64 )"
export EASYDEPLOY_COMPONENT_SYNC_SECRET="$(cat /home/easydeploy/.ssh/id_rsa /var/easydeploy/share/.config/component /var/easydeploy/share/.config/project  /var/easydeploy/share/.config/deploy_env | rhash --sha512 - | cut -c1-64)"
export EASYDEPLOY_ENV_SYNC_SECRET="$(cat /home/easydeploy/.ssh/id_rsa /var/easydeploy/share/.config/deploy_env /var/easydeploy/share/.config/project | rhash --sha512 - | cut -c1-64)"

known_hosts="\"localhost\""
for m in $(cat machines.txt | cut -d: -f2 | tr '\n' ' ')
do
    known_hosts="${known_hosts},\"${m}\""
done


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

        },
         {
            "secret": "$EASYDEPLOY_ENV_SYNC_SECRET",
            "dir": "/var/easydeploy/share/.config/sync",
            "use_relay_server": true,
            "use_tracker": true,
            "use_dht": false,
            "search_lan": true,
            "use_sync_trash": true,
            "known_hosts": [
                    $known_hosts
            ]
        }
    ]
}
EOF
echo 'AUTOSTART="all"' > /etc/default/btsync
sudo chown -R easydeploy:easydeploy /var/easydeploy/share/sync
sudo chown -R easydeploy:easydeploy /etc/btsync/default.conf
sudo chmod 600 /etc/btsync/default.conf
sudo service btsync start
touch /var/easydeploy/.install/btsync
fi


#Serf is used for service discovery and admin tasks
if [ ! -f /var/easydeploy/.install/serf ]
then
    echo "Installing serf for node discovery and communication"
    sudo apt-get install -y unzip
    [ -f 0.5.0_linux_amd64.zip ] || wget https://dl.bintray.com/mitchellh/serf/0.5.0_linux_amd64.zip
    unzip 0.5.0_linux_amd64.zip
    sudo mv -f serf /usr/local/bin
    [ -d /etc/serf ] || sudo mkdir /etc/serf
    sudo cp -f serf-event-handler.sh /etc/serf/event-handler.sh
    [ -d /etc/serf ] || sudo mkdir /etc/serf
    [ -d /etc/serf/handlers ] && sudo rm -rf /etc/serf/handlers
    sudo cp -rf serf-handlers /etc/serf/handlers
    sudo chmod 755 /etc/serf/handlers/*
    sudo chmod 755 /etc/serf/event-handler.sh
    touch /var/easydeploy/.install/serf
fi

#Logstash is used for log aggregation
if [ ! -f /var/easydeploy/.install/logstash ]
then
    if [ ! -d /usr/local/logstash ]
    then
        wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.tar.gz
        tar -zxvf logstash-1.4.0.tar.gz
        mv logstash-1.4.0 /usr/local/logstash
    fi

cat > /etc/logstash.conf <<EOF
input {
  file {
  add_field => {
    component => "$(cat /var/easydeploy/share/.config/component)"
    env =>  "$(cat /var/easydeploy/share/.config/deploy_env)"
    host => "$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')"

    }

    type => "syslog"
    path => [ "/var/log/messages", "/var/log/syslog", "/var/log/*.log",  "/var/log/easydeploy/*.log" ]
  }
}

output { stdout {} }
EOF
    touch /var/easydeploy/.install/logstash
fi


if [ ! -f /var/easydeploy/.install/sysdig ]
then
    echo "Adding sysdig for diagnostics"
    curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash

    touch /var/easydeploy/.install/sysdig
fi

echo "Adding cron tasks"

echo "*/5 * * * * root /home/easydeploy/bin/check_for_restart.sh &>  /var/log/easydeploy/restart.log" > /etc/cron.d/restart

if [[ "${EASYDEPLOY_UPDATE_CRON}" != "none" ]]
then
echo "${EASYDEPLOY_UPDATE_CRON} root /home/easydeploy/bin/update.sh $[ ( $RANDOM % 3600 )  + 1 ]s &> /var/log/easydeploy/update.log" > /etc/cron.d/update
fi

chmod 755 /etc/cron.d/*


sudo su - easydeploy -c "crontab" <<EOF2
0 * * * * find /var/easydeploy/share/tmp/hourly -mmin +60 -exec rm {} \;
0 3 * * * find /var/easydeploy/share/tmp/daily  -mtime +1 -exec rm {} \;
0 4 * * * find /var/easydeploy/share/tmp/monthly -mtime +31 -exec rm {} \;
EOF2

cd

if [ ! -f /var/easydeploy/.install/docker ]
then
    echo "Installing Docker"
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
    sudo apt-get update  -y
    sudo apt-get -y install linux-image-extra-`uname -r`
    sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
    sudo apt-get -y update
    sudo apt-get install -y lxc-docker
    #sudo addgroup worker docker
    sudo addgroup easydeploy docker
    sudo chmod a+rwx /var/run/docker.sock
    sudo chown -R easydeploy:easydeploy /home/easydeploy/
    cd /home/easydeploy/deployment
    sudo service docker start || true
    touch /var/easydeploy/.install/docker
fi

sudo chown -R easydeploy:easydeploy /var/easydeploy

sudo [ -d /home/easydeploy/modules ] && rm -rf /home/easydeploy/modules
sudo cp -r $DIR/modules /home/easydeploy
sudo chown easydeploy:easydeploy /var/log/easydeploy
sudo chown easydeploy:easydeploy /var/easydeploy


 #Pre installation custom tasks
[ -f /home/easydeploy/deployment/pre-install.sh ] && sudo bash /home/easydeploy/deployment/pre-install.sh




echo "Building docker container"
sudo su easydeploy -c "/home/easydeploy/bin/build.sh"
sudo chmod a+rwx /var/run/docker.sock
cd


echo "Configuring firewall"
sudo ufw allow 22   #ssh
sudo ufw allow 7946 #serf
sudo ufw allow 9595 #btsync

for port in ${EASYDEPLOY_PORTS} ${EASYDEPLOY_EXTERNAL_PORTS}
do
    sudo ufw allow ${port}
done

yes | sudo ufw enable



sudo [ -d /home/easydeploy/template ] || mkdir /home/easydeploy/template
sudo cp template-run.conf /home/easydeploy/template/




if [ ! -f /var/easydeploy/.install/supervisord ]
then
    echo "Installing supervisor for process monitoring"
    sudo apt-get install -y supervisor timelimit

    touch /var/easydeploy/.install/supervisord
fi

sudo /bin/bash <<EOF
export COMPONENT=${COMPONENT}
export EASYDEPLOY_HOST_IP=$EASYDEPLOY_HOST_IP
export DEPLOY_ENV=$DEPLOY_ENV
export EASYDEPLOY_PROCESS_NUMBER=${EASYDEPLOY_PROCESS_NUMBER}
envsubst < template-run.conf  > /etc/supervisor/conf.d/run.conf
EOF


echo "Starting/Restarting services"
sudo service supervisor stop || true
sudo docker kill $(docker ps -q) || true
sudo timelimit -t 30 -T 5 service docker stop
[ -e  /tmp/supervisor.sock ] && sudo unlink /tmp/supervisor.sock
[ -e  /var/run/supervisor.sock  ] && sudo unlink /var/run/supervisor.sock
sleep 10
sudo killall docker || true
sudo service docker start
sudo service supervisor restart || true
sudo supervisorctl restart all
sudo cp rc.local /etc
sudo chmod 755 /etc/rc.local
sudo /etc/rc.local

#Security (always the last thing hey!)
if [ !  -f /var/easydeploy/.install/hardened ]
then
echo "Hardening"
#sudo apt-get install -y denyhosts
sudo apt-get install -y fail2ban denyhosts
touch /var/easydeploy/.install/hardened
fi

[ -f  /home/easydeploy/deployment/post-install.sh ] && sudo bash /home/easydeploy/deployment/post-install.sh
[ -f  /home/easydeploy/deployment/post-install-userland.sh ] && sudo su  easydeploy "cd; bash  /home/easydeploy/deployment/post-install.sh"

echo "Done"

exit 0
