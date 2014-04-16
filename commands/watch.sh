#!/bin/bash -eu
cd $(dirname $0) &> /dev/null
. common.sh
profileMachine=$(../providers/${PROVIDER}/list-machines-by-ip.sh $(machineName) | tail -1)
ssh -t -o "StrictHostKeyChecking no" ${USERNAME}@${profileMachine} "watch 'serf query -timeout=60s -tag project=${PROJECT}  -tag deploy_env=${DEPLOY_ENV} -no-ack health'"



