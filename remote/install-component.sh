#!/bin/sh
set -eux
cd $(dirname $0)
DIR=$(pwd)

function dockerfileExtensions() {
    while read line
    do
        command=$(echo $line | cut -d" " -f1)
        case "$command" in
        MOD) bash ${DIR}/modules/$(echo $line | sed 's/^MOD[\\t ]*//g') ;;
        *) echo "$line";;
        esac
    done

}

export COMPONENT=$1
shift
export DEPLOY_ENV=$1
shift
export APP_ARGS="$@"
export EASYDEPLOY_PORTS=80
export EASYDEPLOY_UPDATE_CRON="0/4 * * * *"
export EASYDEPLOY_PACKAGES=
export EASYDEPLOY_STATE="stateful"
export EASYDEPLOY_PROCESS_NUMBER=1
export EASYDEPLOY_EXTERNAL_PORTS=
export EASYDEPLOY_UPDATE_CRON=none

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
sudo [ -d /var/easydeploy/share ] || mkdir /var/easydeploy/share
sudo chown easydeploy:easydeploy /var/log/easydeploy
sudo chown easydeploy:easydeploy /var/easydeploy

#store useful info for scripts
echo ${EASYDEPLOY_STATE} > /var/easydeploy/share/.config/edstate
echo ${APP_ARGS} > /var/easydeploy/share/.config/app_args
echo ${COMPONENT} > /var/easydeploy/share/.config/component
sudo chown easydeploy:easydeploy /var/easydeploy/share

sudo [ -d /home/easydeploy/template ] || mkdir /home/easydeploy/template
sudo mv -f run.sh update.sh /home/easydeploy/bin
sudo chmod 755 /home/easydeploy/bin/*
sudo /bin/bash <<EOF
export COMPONENT=${COMPONENT}
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

#sudo addgroup worker docker
sudo addgroup easydeploy docker
sudo chmod a+rwx /var/run/docker.sock
sudo chown -R easydeploy:easydeploy /home/easydeploy/
cd /home/easydeploy/config
cat Dockerfile | dockerfileExtensions > Dockerfile.processed
mv -f  Dockerfile Dockerfile.orig
mv -f  Dockerfile.processed Dockerfile
sudo su easydeploy -c "cd /home/easydeploy/config ; docker build -t ${COMPONENT} ."
mv -f Dockerfile.orig Dockerfile
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
