#!/bin/bash

touch /tmp/.install-in-progress

mkdir -p /var/easydeploy/share/.config/

if /sbin/ifconfig | grep "eth0 "
then
    /sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' > /var/easydeploy/share/.config/ip
else
    /sbin/ifconfig p1p1 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' > /var/easydeploy/share/.config/ip
fi

error() {
   echo "**** FAIL ****"
   sourcefile=$1
   lineno=$2
   code=$3
   echo "$1:$2" $3
   set +e
   exit $3
}

trap 'error "${BASH_SOURCE}" "${LINENO}" "$?"' ERR

set -eux

export DATACENTER=$1
shift
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

export OTHER_ARGS="$@"
cd

#http://serverfault.com/questions/500764/dpkg-reconfigure-unable-to-re-open-stdin-no-file-or-directory
export DEBIAN_FRONTEND=noninteractive
#export LANGUAGE=en_US.UTF-8
#export LANG=en_US.UTF-8
#export LC_ALL=en_US.UTF-8
#locale-gen en_US.UTF-8
#dpkg-reconfigure locales

#Optional installation components, to install them set the flag in ~/.ezd/bin/pre-bootstrap.sh or ./ezd/bin/pre-bootstrap.sh

INSTALL_ZERO_MQ_FLAG=
INSTALL_JAVA_FLAG=
INSTALL_LOGSTASH_FORWARDER_FLAG=
INSTALL_SQUID_FLAG=
INSTALL_SYSDIG_FLAG=

[[ -f ~/user-scripts/pre-bootstrap.sh ]] &&  . ~/user-scripts/pre-bootstrap.sh || :

if [ ! -f .bootstrapped ]
then

    sudo apt-get -q install -y dnsutils bind9

    echo "nameserver 127.0.0.1" > /etc/resolvconf/resolv.conf.d/head
    service bind9 restart

    sudo apt-get install linux-image-$(uname -r)

    if !  grep "nameserver 8.8.8.8" /etc/resolv.conf
    then
        echo "Fixing resolv.conf"
        echo "nameserver 8.8.8.8" >> /etc/resolv.conf
        echo "nameserver 8.8.4.4" >> /etc/resolv.conf
    fi

    cat > /etc/security/limits.conf <<EOF
*   soft    nofile      65536
*   hard    nofile      65536
*   soft    nproc       500
*   hard    nproc       5000
EOF



    #sudo locale-gen en_GB.UTF-8
    #sudo bash <<EOF
    #echo 'LANG="en_GB.UTF-8"' > /etc/default/locale
    #EOF

    function addNewUser() {
        echo "Building $1 user"
        export password="$(echo $(date) "$@" | md5sum)"
        [ -d /home/$1 ] || sudo adduser $1 <<EOF
        ${password}
        ${password}
EOF
        echo "Cleaning out /home/$1"
        sudo rm -rf /home/$1/*
        [ -d ./home/$1/.ssh ] || sudo cp -r .ssh /home/$1/
        sudo cp -f ~/.ssh/easydeploy_id_rsa  /home/$1/.ssh/id_rsa
        sudo cp -f ~/.ssh/easydeploy_id_rsa.pub  /home/$1/.ssh/id_rsa.pub
        sudo cat ~/keys/*.pub >  /home/$1/.ssh/authorized_keys
        chmod 700  /home/$1/.ssh/
        chmod 600  /home/$1/.ssh/*
        chown -R $1:$1 /home/$1/.ssh/
    }


    addNewUser easydeploy
    addNewUser easyadmin

    echo "easyadmin	ALL=(ALL:ALL) NOPASSWD: /usr/bin/supervisorctl, /bin/su easydeploy, /bin/kill, /sbin/shutdown, /sbin/reboot, /bin/ls, /ezbin/*,  /ezubin/*, /usr/bin/unattended-upgrade"  > /etc/sudoers.d/easyadmin
    echo "easydeploy ALL=(ALL:ALL) NOPASSWD: /usr/local/bin/weave, /usr/local/bin/docker-ns" > /etc/sudoers.d/easydeploy

    chmod 0440 /etc/sudoers.d/easyadmin

    sudo mkdir -p /var/run/easydeploy
    sudo chown easydeploy:easydeploy /var/run/easydeploy


    echo "Installing basic pre-requisites"
    sudo apt-get -qq update

    sudo apt-get -q install  -y git software-properties-common unattended-upgrades incron fileschanged dialog zip sharutils apparmor monit ntp netcat-traditional mosh parallel jq ethtool conntrack parallel


    #GNU Parallel
    if [[ -f /etc/parallel/config ]]
    then
        sudo rm /etc/parallel/config
    fi

    if [[ -n "$INSTALL_JAVA_FLAG" ]]
    then
        sudo add-apt-repository ppa:chris-lea/zeromq
        sudo add-apt-repository ppa:webupd8team/java
        sudo apt-get -qq update
        echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
        yes | sudo apt-get -q install -y oracle-java8-installer
        sudo apt-get -q install -y oracle-java8-set-default
    fi
    if [[ -n "$INSTALL_ZERO_MQ_FLAG" ]]
    then
        sudo apt-get -q install -y libzmq3-dbg libzmq3-dev libzmq3
    fi
    if [[ -n "$INSTALL_LOGSTASH_FORWARDER_FLAG" ]]
    then
        sudo apt-get -q install -y gccgo-go
        git clone git://github.com/elasticsearch/logstash-forwarder.git
        cd logstash-forwarder
        go build
        cd -
        mv logstash-forwarder /usr/local/
    fi
    sudo chown -R easydeploy:easydeploy  /home/easydeploy/
    echo 'PATH=$PATH:$HOME/bin:/ezbin:/ezubin' >> ~/.bash_profile
    echo 'PATH=$PATH:$HOME/bin:$HOME/usr/bin:/ezbin:/ezubin' >> /home/easydeploy/.bash_profile
    echo 'PATH=$PATH:$HOME/bin:$HOME/usr/bin:/ezbin:/ezubin' >> /home/easyadmin/.bash_profile

    echo "Adding cron tasks"
    sudo apt-get -q install -y duplicity
    pathline="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"
    echo $pathline > /etc/cron.d/restart
    echo "*/13 * * * * root /bin/bash -l -c '/home/easydeploy/bin/check_for_restart.sh &>  /var/log/easydeploy/restart.log'" >> /etc/cron.d/restart
    echo $pathline > /etc/cron.d/backup
    echo "7 * * * * easydeploy /bin/bash -l -c '/home/easydeploy/bin/backup.sh &>  /var/log/easydeploy/backup.log'" >> /etc/cron.d/backup
    echo $pathline > /etc/cron.d/security
    echo "0 */4 * * * root /bin/bash -l -c '/usr/bin/unattended-upgrade &>  /var/log/easydeploy/security-update.log'" >> /etc/cron.d/security
    echo $pathline > /etc/cron.d/clean
    echo "0 5 * * * root /bin/bash -l -c '/home/easydeploy/bin/clean.sh &>  /var/log/easydeploy/clean.log'" >> /etc/cron.d/clean


    [ -f ~/user-scripts/post-bootstrap.sh ] && bash ~/user-scripts/post-bootstrap.sh

    touch .bootstrapped

fi

echo "Installing ${COMPONENT} on ${DEPLOY_ENV}"
bash ~/remote/install-component.sh ${DATACENTER} ${COMPONENT} ${DEPLOY_ENV} ${PROJECT} ${BACKUP_HOST} ${MACHINE_NAME} ${TARGET_COMPONENT} ${EASYDEPLOY_REMOTE_IP_RANGE} ${OTHER_ARGS}
rm -f /tmp/.install-in-progress
echo "**** SUCCESS ****"
exit 0



