#!/bin/bash -eu

chmod 755 ~/bin/*

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


cd $(dirname $0)
DIR=$(pwd)


echo "Setting defaults"
export COMPONENT=$1
shift
export DEPLOY_ENV=$1
shift
export PROJECT=$1
shift
export BACKUP_HOST=$1
shift
export MACHINE_NAME=$1
shift
export TARGET_COMPONENT=$1
shift
export EASYDEPLOY_REMOTE_IP_RANGE=$1
shift

export APP_ARGS="$@"
export EASYDEPLOY_PRIMARY_ADMIN_SERVER=
export EASYDEPLOY_SECONDARY_ADMIN_SERVER=
export EASYDEPLOY_PORTS=
export EASYDEPLOY_PRIMARY_PORT=
export EASYDEPLOY_UPDATE_CRON="0 4 * * *"
export EASYDEPLOY_PACKAGES=
export EASYDEPLOY_STATE="stateful"
export EASYDEPLOY_PROCESS_NUMBER=1
export EASYDEPLOY_EXTERNAL_PORTS=
export EASYDEPLOY_SERVICE_CHECK_INTERVAL=300s
export EASYDEPLOY_UPDATE_CRON=none
export DEBIAN_FRONTEND=noninteractive

echo "Creating directories"
sudo [ -d /home/easydeploy/bin ] || mkdir /home/easydeploy/bin
sudo [ -d /home/easydeploy/usr/bin ] || mkdir -p /home/easydeploy/usr/bin
sudo [ -d /home/easydeploy/usr/etc ] || mkdir -p /home/easydeploy/usr/etc
sudo [ -d /var/log/easydeploy ] || mkdir /var/log/easydeploy
sudo [ -d /var/easydeploy ] || mkdir /var/easydeploy
sudo [ -d /var/easydeploy/.install ] || mkdir /var/easydeploy/.install
sudo [ -d /var/easydeploy/share ] || mkdir /var/easydeploy/share
sudo [ -d /var/easydeploy/share/tmp ] || mkdir /var/easydeploy/share/tmp
sudo [ -d /var/easydeploy/share/tmp/hourly ] || mkdir /var/easydeploy/share/tmp/hourly
sudo [ -d /var/easydeploy/share/tmp/daily ] || mkdir /var/easydeploy/share/tmp/daily
sudo [ -d /var/easydeploy/share/tmp/monthly ] || mkdir /var/easydeploy/share/tmp/monthly
sudo [ -d /var/easydeploy/share/backup ] || mkdir /var/easydeploy/share/backup
sudo [ -d /var/easydeploy/share/sync ] || mkdir /var/easydeploy/share/sync
sudo [ -d /var/easydeploy/share/sync/global ] || mkdir /var/easydeploy/share/sync/global
sudo [ -d /var/easydeploy/share/sync/discovery ] || mkdir /var/easydeploy/share/sync/discovery
sudo [ -d /var/easydeploy/share/sync/env ] || mkdir /var/easydeploy/share/sync/env
sudo [ -d /var/easydeploy/share/.config/ ] || mkdir /var/easydeploy/share/.config/
sudo [ -d /var/easydeploy/share/.config/sync/discovery ] || mkdir -p /var/easydeploy/share/.config/sync/discovery

[ -d /ezlog ] || sudo ln -s  /var/log/easydeploy /ezlog
[ -d /ezshare ] || sudo ln -s  /var/easydeploy/share /ezshare
[ -d /ez ] || sudo ln -s  /var/easydeploy /ez
[ -d /ezbin ] || sudo ln -s  /home/easydeploy/bin /ezbin
[ -d /ezubin ] || sudo ln -s  /home/easydeploy/usr/bin /ezubin
[ -d /ezuetc ] || sudo ln -s  /home/easydeploy/usr/etc /ezuetc
[ -d /ezsync ] || sudo ln -s  /var/easydeploy/share/sync /ezsync
[ -d /ezbackup ] || sudo ln -s  /var/easydeploy/share/backup /ezbackup
[ -d /eztmp ] || sudo ln -s  /var/easydeploy/share/tmp /eztmp


if /sbin/ifconfig | grep "eth0 "
then
    /sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' > /var/easydeploy/share/.config/ip
else
    /sbin/ifconfig p1p1 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' > /var/easydeploy/share/.config/ip
fi

export EASYDEPLOY_HOST_IP=$(</var/easydeploy/share/.config/ip)


sudo cp -f *.sh /home/easydeploy/bin
mv -f bashrc_profile ~/.bashrc_profile
sudo mv .dockercfg /home/easydeploy/
[ -d /home/easydeploy/project/ezd/bin/ ] || mkdir -p /home/easydeploy/project/ezd/bin/
[ -d /home/easydeploy/project/ezd/etc/ ] || mkdir -p /home/easydeploy/project/ezd/etc/
cp -rf ~/project/*  /home/easydeploy/project/
[ -d ~/user-scripts ] && sudo cp -rf ~/user-scripts/*  /home/easydeploy/project/ezd/bin/
[ -d ~/user-config ] && sudo cp -rf ~/user-config/*  /home/easydeploy/project/ezd/etc/
sudo chown easydeploy:easydeploy /home/easydeploy/.dockercfg
sudo chown -R easydeploy:easydeploy /home/easydeploy/project
sudo chmod 700 /home/easydeploy/.dockercfg
sudo chmod 755 /home/easydeploy/bin/*
sudo chmod 755 /home/easydeploy/project/ezd/bin/* ||:


echo "Setting up deployment project"
sudo su - easydeploy <<EOF
set -eu
cd /home/easydeploy
chmod 600 ~/.ssh/*
chmod 700 ~/.ssh
EOF

echo ${EASYDEPLOY_HOST_IP} > /var/easydeploy/share/.config/ip

echo "Reading config"
. /home/easydeploy/project/ezd/etc/ezd.sh


#store useful info for scripts
echo "Saving config"
echo ${EASYDEPLOY_STATE} > /var/easydeploy/share/.config/edstate
echo ${APP_ARGS} > /var/easydeploy/share/.config/app_args
echo ${COMPONENT} > /var/easydeploy/share/.config/component
echo ${DEPLOY_ENV} > /var/easydeploy/share/.config/deploy_env
echo ${PROJECT} > /var/easydeploy/share/.config/project
echo ${BACKUP_HOST} > /var/easydeploy/share/.config/backup_host
echo ${MACHINE_NAME} > /var/easydeploy/share/.config/hostname
echo ${TARGET_COMPONENT} > /var/easydeploy/share/.config/target
cp serf_key  /var/easydeploy/share/.config/serf_key
sudo chown easydeploy:easydeploy /var/easydeploy/share

[ -f machines.txt ] && cp -f machines.txt  /var/easydeploy/share/.config/machines.txt


#Install additional host packages, try to avoid that and keep them in
#the Dockerfile where possible.
if [ ! -z "${EASYDEPLOY_PACKAGES}" ]
then
    echo "Installing custom packages ${EASYDEPLOY_PACKAGES}"
    sudo apt-get -q install -y ${EASYDEPLOY_PACKAGES}
fi


#Sync between nodes using btsync
echo "Installing Bit Torrent sync"
if [ ! -f /var/easydeploy/.install/btsync ]
then
sudo apt-get install -q -y  rhash
sudo add-apt-repository -y ppa:tuxpoldo/btsync
sudo apt-get -qq update
echo "n" | sudo apt-get -q install -y btsync
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
    sudo apt-get -q install -y unzip
    [ -f 0.5.0_linux_amd64.zip ] || wget -q https://dl.bintray.com/mitchellh/serf/0.5.0_linux_amd64.zip
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

sudo apt-get -q install -y dnsutils bind9

cat > /etc/bind/ezd.conf <<EOF
zone "ezd" IN {
    type master;
    file "/etc/bind/ezd.zone";
};
EOF


    cat > /etc/bind/ezd.zone <<'EOF'
$ORIGIN ezd.
$TTL 5
ezd. IN	SOA	localhost. support.cazcade.com. (
		2001062501 ; serial
		5      ; refresh after 5 secs
		5       ; retry after 5 secs
		5     ; expire after 5 secs
		5 )    ; minimum TTL of 5 secs
;
;

ezd.     IN      NS	    127.0.0.1
EOF


cat > /etc/bind/named.conf.options <<EOF
options {
    listen-on port 53 { any;};
    listen-on-v6 port 53 { ::1; };
	directory "/var/cache/bind";
	allow-query     { any; };
    recursion yes;
    dnssec-enable no;
    dnssec-validation no;
    version "none of your business";
};
	include "/etc/bind/ezd.conf";
EOF



echo "nameserver 127.0.0.1" > /etc/resolvconf/resolv.conf.d/head
service bind9 restart


ports=( ${EASYDEPLOY_PRIMARY_PORT} ${EASYDEPLOY_PORTS} ${EASYDEPLOY_EXTERNAL_PORTS} )
if [ ! -z "$ports" ]
then
primary_port=${ports[0]}

fi



#Logstash is used for log aggregation
if [ ! -f /var/easydeploy/.install/logstash ] && [[ -n "$INSTALL_LOGSTASH_FLAG" ]]
then
    if [ ! -d /usr/local/logstash ]
    then
        wget -q https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.tar.gz
        tar -zxvf logstash-1.4.0.tar.gz
        mv logstash-1.4.0 /usr/local/logstash
    fi


    touch /etc/logstash.conf
    chown easydeploy:easydeploy /etc/logstash.conf
    touch /var/easydeploy/.install/logstash

fi


if [ ! -f /var/easydeploy/.install/sysdig ] && [[ -n "$INSTALL_SYSDIG_FLAG" ]]
then
    echo "Adding sysdig for diagnostics"
    curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash

    touch /var/easydeploy/.install/sysdig
fi

echo "Adding cron tasks"
sudo apt-get -q install -y duplicity
pathline="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"
echo $pathline > /etc/cron.d/restart
echo "*/13 * * * * root /bin/bash -l -c '/home/easydeploy/bin/check_for_restart.sh &>  /var/log/easydeploy/restart.log'" >> /etc/cron.d/restart
echo $pathline > /etc/cron.d/backup
echo "7 * * * * easydeploy /bin/bash -l -c '/home/easydeploy/bin/backup.sh &>  /var/log/easydeploy/backup.log'" >> /etc/cron.d/backup

if [[ ! -z "${EASYDEPLOY_UPDATE_CRON}" ]]
then
echo $pathline > /etc/cron.d/update
echo "${EASYDEPLOY_UPDATE_CRON} root /bin/bash -l -c '/home/easydeploy/bin/update.sh $[ ( $RANDOM % 3600 )  + 1 ]s &> /var/log/easydeploy/update.log'" >> /etc/cron.d/update
fi

echo $pathline > /etc/cron.d/clean
echo "*/13 * * * * root /bin/bash -l -c '/home/easydeploy/bin/clean.sh &>  /var/log/easydeploy/clean.log'" >> /etc/cron.d/clean

chmod 755 /etc/cron.d/*

sudo su - easydeploy -c "crontab" <<EOF2
0 * * * * find /var/easydeploy/share/tmp/hourly -mmin +60 -exec rm {} \;
0 3 * * * find /var/easydeploy/share/tmp/daily  -mtime +1 -exec rm {} \;
0 4 * * * find /var/easydeploy/share/tmp/monthly -mtime +31 -exec rm {} \;
EOF2

cd

if [[ ! -f /var/easydeploy/.install/docker ]]
then
    echo "Installing Docker"
#    sudo apt-get install -y docker.io
    curl -sSL https://get.docker.io/ubuntu/ | sudo sh
#    sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
    #sudo addgroup worker docker
    sudo addgroup easydeploy docker
    sudo chmod a+rwx /var/run/docker.sock
    sudo chown -R easydeploy:easydeploy /home/easydeploy/
    grep "limit nofile 65536 65536" /etc/init/docker.conf || echo "limit nofile 65536 65536" >> /etc/init/docker.conf
    sudo service docker start || true
    touch /var/easydeploy/.install/docker
fi

curl -L https://github.com/docker/fig/releases/download/0.5.2/linux > /usr/local/bin/fig
chmod +x /usr/local/bin/fig

sudo chown -R easydeploy:easydeploy /var/easydeploy

sudo [ -d /home/easydeploy/modules ] && rm -rf /home/easydeploy/modules
sudo cp -r $DIR/modules /home/easydeploy
sudo chown easydeploy:easydeploy /var/log/easydeploy
sudo chown easydeploy:easydeploy /var/easydeploy


 #Pre installation custom tasks
[ -f /home/easydeploy/project/ezd/bin/pre-install.sh ] && sudo bash /home/easydeploy/project/ezd/bin/pre-install.sh

if [ -f /home/easydeploy/project/ezd/bin/pre-install-user.sh ]
then
    sudo su - easydeploy <<EOF
set -eu
bash /home/easydeploy/project/ezd/bin/pre-install-user.sh
EOF
fi

sudo chmod a+rwx /var/run/docker.sock

echo "Configuring firewall"
sudo ufw allow 22    #ssh
sudo ufw allow 7946  #serf
sudo ufw allow 17123 #???
sudo ufw allow 1888  #status check for lb
sudo ufw allow 9595  #btsync
sudo ufw allow from 172.16.0.0/12 to any port 53 #dns from containers
sudo ufw allow from 172.16.0.0/12 to any port 8125 #dogstatsd from containers
if [ ! -z "$EASYDEPLOY_REMOTE_IP_RANGE" ]
then
    ufw allow from $EASYDEPLOY_REMOTE_IP_RANGE to any 60000:60050  # mosh
    ufw allow from $EASYDEPLOY_REMOTE_IP_RANGE to any port 8500
    ufw allow from $EASYDEPLOY_REMOTE_IP_RANGE to any port 8400
    ufw allow from $EASYDEPLOY_REMOTE_IP_RANGE to any port 8600
fi

for port in ${EASYDEPLOY_PORTS} ${EASYDEPLOY_EXTERNAL_PORTS}
do
    sudo ufw allow ${port}
done

yes | sudo ufw enable


if [[ -n "$INSTALL_SQUID_FLAG" ]]
then
    #Squid
    sudo apt-get -q install -y squid3
    cat > /etc/squid3/squid.conf <<EOF
    acl all src all
    http_port 3128
    http_access allow all

    # We recommend you to use at least the following line.
    hierarchy_stoplist cgi-bin ?

    # Uncomment and adjust the following to add a disk cache directory.
    cache_dir ufs /var/spool/squid3 10000 16 256

    # Leave coredumps in the first cache dir
    coredump_dir /var/spool/squid3
EOF
    [ -d /var/spool/squid3 ] || mkdir /var/spool/squid3
    squid3 -z
    chown -R proxy:proxy  /var/spool/squid3
fi

sudo [ -d /home/easydeploy/template ] || mkdir /home/easydeploy/template
sudo cp template-run.conf /home/easydeploy/template/




if [ ! -f /var/easydeploy/.install/supervisord ]
then
    echo "Installing supervisor for process monitoring"
    sudo apt-get install -q -y supervisor timelimit

    touch /var/easydeploy/.install/supervisord
fi

sudo /bin/bash <<EOF
export COMPONENT=${COMPONENT}
export EASYDEPLOY_HOST_IP=$EASYDEPLOY_HOST_IP
export DEPLOY_ENV=$DEPLOY_ENV
export EASYDEPLOY_PROCESS_NUMBER=${EASYDEPLOY_PROCESS_NUMBER}
envsubst < template-run.conf  > /etc/supervisor/conf.d/run.conf
EOF




sudo cp rc.local /etc
sudo chmod 755 /etc/rc.local
sudo /etc/rc.local

#Monitoring
echo "Adding Monitoring"
if [ -f /home/easydeploy/project/ezd/etc/newrelic-license-key.txt ]
then
    echo "Adding New Relic support"
    sudo echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list
    wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
    sudo apt-get -qq update
    sudo apt-get -q install -y newrelic-sysmond
    sudo nrsysmond-config --set license_key=$(cat /home/easydeploy/project/ezd/etc/newrelic-license-key.txt)
    /etc/init.d/newrelic-sysmond start
fi

if [[ $DEPLOY_ENV == prod* ]]  && [[ -f  /home/easydeploy/project/ezd/etc/boundary-token.txt ]]
then
    echo "Adding Boundary support"
    curl -s -d "{\"token\":\"$(cat /home/easydeploy/project/ezd/etc/boundary-token.txt)\"}" -H 'Content-Type: application/json' https://premium.boundary.com/agent/install | sh
fi

sudo apt-get -q install -y dstat

if [[ $DEPLOY_ENV == prod* ]]  && [[ -f  /home/easydeploy/project/ezd/etc/datadog-api-key.txt ]]
then
echo "Installing DataDog agent"
    DD_API_KEY=$(< /home/easydeploy/project/ezd/etc/datadog-api-key.txt) bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)" &> /dev/null
fi
#if [ -f /home/easydeploy/project/ezd/etc/scalyr-license-key.txt ]
#then
#    wget https://www.scalyr.com/scalyr-repo/stable/latest/installScalyrRepo.sh
#    sudo bash ./installScalyrRepo.sh
#    sudo apt-get install scalyr-agent
#    sudo scalyr-agent-config --run_as root --write_logs_key -   < /home/easydeploy/project/ezd/etc/scalyr-license-key.txt
#    cp ~/agentConfig.json  /etc/scalyrAgent/agentConfig.json
#    sudo scalyr-agent start
#fi


#Security (always the last thing hey!)
if [ !  -f /var/easydeploy/.install/hardened ]
then
    echo "Hardening"
    #sudo apt-get install -y denyhosts
    sudo apt-get -q install -y fail2ban
    touch /var/easydeploy/.install/hardened
fi

[ -f  /home/easydeploy/project/ezd/bin/post-install.sh ] && sudo bash /home/easydeploy/project/ezd/bin/post-install.sh
[ -f  /home/easydeploy/project/ezd/bin/post-install-userland.sh ] && sudo su  easydeploy "cd; bash  /home/easydeploy/project/ezd/bin/post-install-userland.sh"


echo "Starting/Restarting services"
sudo service supervisor stop || true
sudo docker kill $(docker ps -q) || true
sudo timelimit -t 30 -T 5 service docker stop || :
[ -e  /tmp/supervisor.sock ] && sudo unlink /tmp/supervisor.sock
[ -e  /var/run/supervisor.sock  ] && sudo unlink /var/run/supervisor.sock
sleep 10
sudo killall docker || true
sudo service docker start
sudo service supervisor restart || true
sleep 10
sudo supervisorctl restart all  || true


echo "Done"

exit 0
