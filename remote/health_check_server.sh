#!/bin/bash -eux
while true
do
    /bin/nc.traditional -l -p 1888 -c "/ezbin/health_check_http.sh"
done