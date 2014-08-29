#!/bin/bash -eux
/ezbin/health_check_http

while  ! tail -1 < /tmp/hco | grep FAIL
do
    /bin/nc.traditional -l -p 1888 -c "/ezbin/health_check_http"
done