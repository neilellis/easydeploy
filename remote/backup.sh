#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

 backup=$(cat /var/easydeploy/share/.config/backup_host)
 host_ip=$(/sbin/ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
 component=$(cat /var/easydeploy/share/.config/component)
 deploy_env=$(cat /var/easydeploy/share/.config/deploy_env)
 project=$(cat /var/easydeploy/share/.config/project)
 base_url="scp://easydeploy@${backup}/var/easydeploy/backups/${deploy_env}/${project}/${host_ip}/"
duplicity --full-if-older-than 1M /var/easydeploy/share/backup ${base_url}



