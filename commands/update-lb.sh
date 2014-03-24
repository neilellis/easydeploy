#!/bin/bash  -x


trap 'echo FAILED' ERR

cd $(dirname $0) &> /dev/null
. common.sh

set -x

bash ../templates/lb-haproxy.cfg >  /tmp/haproxy.tmp

for ip in $(../providers/${PROVIDER}/list-machines-by-ip.sh $(targetMachineName) | tr '\n' ' ')
do
    echo "    server  ${LB_TARGET_COMPONENT}-${ip} ${ip}:80 weight 1 maxconn ${LB_MAXCONN} check inter ${LB_CHECK_INTERVAL}" >> /tmp/haproxy.tmp
done

echo "" >> /tmp/haproxy.tmp

#foreach($machine in $downstreamMachines)
#end
for ip in  $(../providers/${PROVIDER}/list-machines-by-ip.sh $(machineName))
do
    scp -o "StrictHostKeyChecking no"  /tmp/haproxy.tmp ${USERNAME}@${ip}:/var/easydeploy/share/haproxy.cfg
    ssh -o "StrictHostKeyChecking no"  ${USERNAME}@${ip} "reboot"
    sleep 30
done