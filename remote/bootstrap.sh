#!/bin/sh

error() {
    echo "**** EASYDEPLOY-COMPONENT-INSTALL-FAILED ****"
   sourcefile=$1
   lineno=$2
   code=$3
   echo "$1:$2" $3
   set +e
   cat $1 | mail   -s  "Error during build of $HOSTNAME ($IP) - $1:$2"   neil@cazcade.com
   exit $3
}

trap 'error "${BASH_SOURCE}" "${LINENO}" "$?"' ERR
set -eux
export GIT_URL_HOST=$1
export GIT_URL_USER=$2
export COMPONENT=$3
export DEPLOY_ENV=$4
export OTHER_ARGS=$5
cd

if !  grep "nameserver 8.8.8.8" /etc/resolv.conf
then
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
fi



#sudo locale-gen en_GB.UTF-8
sudo bash <<EOF
echo 'LANG="en_GB.UTF-8"' > /etc/default/locale
EOF


export password="$(echo $(date) "$@" | md5sum)"
[ -d /home/easydeploy ] || sudo adduser easydeploy <<EOF
${password}
${password}
EOF
rm -rf /home/easydeploy/*
sudo addgroup easydeploy sudo
[ -d ./home/easydeploy/.ssh ] || cp -r .ssh /home/easydeploy/
cp -f ~/.ssh/easydeploy_id_rsa  /home/easydeploy/.ssh/id_rsa
cp -f ~/.ssh/easydeploy_id_rsa.pub  /home/easydeploy/.ssh/id_rsa.pub
mkdir -p /var/run/easydeploy
chown easydeploy:easydeploy /var/run/easydeploy
sudo apt-get update
sudo apt-get install -y git software-properties-common
echo $COMPONENT > /home/easydeploy/.install-type
chown -R easydeploy:easydeploy  /home/easydeploy/
su - easydeploy <<EOF
set -eux
cd /home/easydeploy
chmod 600 ~/.ssh/*
chmod 700 ~/.ssh
ssh -o StrictHostKeyChecking=no git@${GIT_URL_HOST}  /bin/bash  &> /dev/null</dev/null  || true
git clone git@${GIT_URL_HOST}:${GIT_URL_USER}/easydeploy-${COMPONENT}.git
if [ ${DEPLOY_ENV} == "prod" ] ||  [ ${DEPLOY_ENV} == "alt-prod" ]
then
    echo "Using master branch"
    cd easydeploy-${COMPONENT}
    git checkout master
    cd -
else
    echo "Using ${DEPLOY_ENV}  branch"
    cd easydeploy-${COMPONENT}
    git checkout ${DEPLOY_ENV}
    cd -
fi
ln -s /home/easydeploy/easydeploy-${COMPONENT}/ /home/easydeploy/config
cp -f ~/.ssh/id_rsa  /home/easydeploy/config/id_rsa
cp -f ~/.ssh/id_rsa.pub  /home/easydeploy/config/id_rsa.pub
EOF



echo "Installing ${COMPONENT} on ${DEPLOY_ENV}"
bash ./install-component.sh ${COMPONENT} ${DEPLOY_ENV} ${OTHER_ARGS}
echo "**** EASYDEPLOY-COMPONENT-INSTALL-FINISHED ****"
exit 0



