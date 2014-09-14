#!/bin/bash -eux
killall btsync || :
[ -d /var/easydeploy/.btsync ] || mkdir -p /var/easydeploy/.btsync
/usr/local/bin/btsync --nodaemon --config /etc/btsync.conf
