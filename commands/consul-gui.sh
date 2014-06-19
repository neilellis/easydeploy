#!/bin/sh
cd $(dirname $0)
. common.sh

set -eux

machine=$( ../providers/${PROVIDER}/list-machines-by-ip.sh $(mc_name) | tail -1 )

/usr/local/bin/consul agent -ui-dir ~/.ezd/client_install/consul_ui/ -config-file ~/.ezd/client_install/consul.json  -join=$machine -node=gui  -data-dir=/tmp
