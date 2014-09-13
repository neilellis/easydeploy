#!/bin/bash -eux
/ezbin/health_check_http.sh

while true
do
    /bin/nc.traditional -l -p 1888 -c "/ezbin/health_check_http.sh"
done