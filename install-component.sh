#!/bin/sh
set -eux

export COMPONENT=$1
export EASYDEPLOY_PORTS=80
export EASYDEPLOY_UPDATE_CRON="0/4 * * * *"
export EASYDEPLOY_PACKAGES=
export EASYDEPLOY_PROCESS_NUMBER=1
export EASYDEPLOY_EXTERNAL_PORTS=

. /home/easydeploy/config/ed.sh

if [ ! -z ${EASYDEPLOY_PACKAGES} ]
then
    sudo apt-get install -y ${EASYDEPLOY_PACKAGES}
fi

[ -f /home/easydeploy/config/pre-install.sh ] && sudo bash /home/easydeploy/config/pre-install.sh

sudo apt-get install -y supervisor
sudo [ -d /home/easydeploy/bin ] || mkdir /home/easydeploy/bin
sudo [ -d /var/log/easydeploy ] || mkdir /var/log/easydeploy
sudo [ -d /var/easydeploy ] || mkdir /var/easydeploy
sudo chown easydeploy:easydeploy /var/log/easydeploy
sudo chown easydeploy:easydeploy /var/easydeploy
sudo [ -d /home/easydeploy/template ] || mkdir /home/easydeploy/template
sudo mv -f run.sh update.sh /home/easydeploy/bin
sudo chmod 755 /home/easydeploy/bin/*
sudo /bin/bash <<EOF
export COMPONENT=${COMPONENT}
export EASYDEPLOY_PROCESS_NUMBER=${EASYDEPLOY_PROCESS_NUMBER}
envsubst < template-run.conf  > /etc/supervisor/conf.d/run.conf
EOF

sudo cp template-run.conf /home/easydeploy/template/

if [ ! -z ${EASYDEPLOY_UPDATE_CRON} ]
then
    sudo crontab <<EOF2
    ${EASYDEPLOY_UPDATE_CRON} /home/easydeploy/bin/update.sh &> /va/log/easydeploy/update.log
EOF2
fi

cd
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
cd /home/easydeploy/config
sudo su easydeploy -c "cd /home/easydeploy/config ; docker build -t ${COMPONENT} ."
sudo chmod a+rwx /var/run/docker.sock
cd

sudo ufw allow 22
for port in ${EASYDEPLOY_PORTS} ${EASYDEPLOY_EXTERNAL_PORTS}
do
sudo ufw allow ${port}
done
yes | sudo ufw enable
sudo service supervisor stop || true
sudo service supervisor start
[ -f  /home/easydeploy/config/post-install.sh ] && sudo bash /home/easydeploy/config/post-install.sh
[ -f  /home/easydeploy/config/post-install-userland.sh ] && sudo su  easydeploy "cd; bash  /home/easydeploy/config/post-install-userland.sh"

exit 0
