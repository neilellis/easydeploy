#!/bin/bash -eux

. /home/easydeploy/bin/env.sh

function buildComponentDnsEntry() {
    while read line
    do
        bash -c "export host_ip=$line; echo \"\${component}.\${project}.\${deploy_env}.comp   IN A   \${host_ip}\""
    done
}

function buildDns() {
    serf members | grep alive | tr -s ' ' | cut -d' ' -f2- | sed 's/:[0-9]*//g' | sed 's/alive //g' | sed 's/,/; export /g' | buildComponentDnsEntry
}


    cat > /etc/bind/ezd.zone <<'EOF'
$ORIGIN ezd.
$TTL 5
ezd. IN	SOA	ns.ezd. support.cazcade.com. (
		2001062501 ; serial
		5      ; refresh after 5 secs
		5       ; retry after 5 secs
		5     ; expire after 5 secs
		5 )    ; minimum TTL of 5 secs
;
;

ezd.     IN      NS	    ns
ns.ezd.  IN      NS	    127.0.0.1
EOF


buildDns >> /etc/bind/ezd.zone
service bind9 reload
