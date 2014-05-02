#!/bin/bash

touch /tmp/.install-in-progress

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

set -eu

export GIT_URL_HOST=$1
shift
export GIT_URL_USER=$1
shift
export COMPONENT=$1
shift
export DEPLOY_ENV=$1
shift
export GIT_BRANCH=$1
shift
export PROJECT=$1
shift
export BACKUP_HOST=$1
shift
export MACHINE_NAME=$1
shift
export TARGET_COMPONENT=$1
shift
export OTHER_ARGS="$@"
cd



if [ ! -f .bootstrapped ]
then

if !  grep "nameserver 8.8.8.8" /etc/resolv.conf
then
    echo "Fixing resolv.conf"
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
fi



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

echo "easyadmin	ALL=(ALL:ALL) NOPASSWD: /usr/bin/supervisorctl, /bin/su easydeploy, /bin/kill, /sbin/shutdown, /sbin/reboot, /bin/ls" > /etc/sudoers.d/easyadmin

chmod 0440 /etc/sudoers.d/easyadmin

sudo mkdir -p /var/run/easydeploy
sudo chown easydeploy:easydeploy /var/run/easydeploy


echo "Installing basic pre-requisites"
sudo apt-get update
sudo apt-get install -y git software-properties-common unattended-upgrades incron fileschanged
sudo add-apt-repository ppa:chris-lea/zeromq
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
yes | sudo apt-get install -y oracle-java8-installer
sudo apt-get install -y oracle-java8-set-default
sudo apt-get install -y libzmq3-dbg libzmq3-dev libzmq3

sudo chown -R easydeploy:easydeploy  /home/easydeploy/

touch .bootstrapped
fi

echo "Installing ${COMPONENT} on ${DEPLOY_ENV}"
bash ./install-component.sh ${COMPONENT} ${DEPLOY_ENV} ${GIT_BRANCH} ${PROJECT} ${BACKUP_HOST} ${MACHINE_NAME} ${TARGET_COMPONENT} ${OTHER_ARGS}
rm -f /tmp/.install-in-progress
echo "**** SUCCESS ****"
exit 0



