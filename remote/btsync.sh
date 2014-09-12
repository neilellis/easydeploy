#!/bin/bash -eux
killall btsync || :
/usr/local/bin/btsync --nodaemon --config /etc/btsync.conf
