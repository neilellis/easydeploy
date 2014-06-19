#!/bin/bash
export EASYDEPLOY_HOST_IP=$(</var/easydeploy/share/.config/ip)
docker run -t -i -p 3128:3128 --dns=${EASYDEPLOY_HOST_IP} neilellis/squid
