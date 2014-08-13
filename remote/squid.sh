#!/bin/bash
export EASYDEPLOY_HOST_IP=$(</var/easydeploy/share/.config/ip)
docker pull neilellis/squid-open
docker run -t -i -p ${EASYDEPLOY_HOST_IP}:3128:3128 --dns=${EASYDEPLOY_HOST_IP} neilellis/squid-open
