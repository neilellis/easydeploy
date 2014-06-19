#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
profileMachine=$(../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tail -1)
ssh -t -o "StrictHostKeyChecking no" ${USERNAME}@${profileMachine} "watch --interval=30 'serf query -timeout=40s -no-ack -tag project=${PROJECT}  -tag deploy_env=${DEPLOY_ENV} health'"



