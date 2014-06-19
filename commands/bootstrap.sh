#!/bin/bash

echo "Starting bootstrap process, please keep this running until your Consul DNS is working correctly"
cd $(dirname $0) &> /dev/null
. common.sh
export IP_ADDRESS=$(../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tail -1)
echo "IP = $IP_ADDRESS"
set -eu
ssh  -o "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "supervisorctl stop consul; killall consul; /home/easydeploy/bin/consul-agent.sh -bootstrap &"
sleep 3600
ssh  -o "StrictHostKeyChecking no" ${USERNAME}@${IP_ADDRESS} "killall consul; supervisorctl start consul"
