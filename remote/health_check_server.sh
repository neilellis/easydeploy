#!/bin/bash -eux
/ezbin/health_check_http.sh

while  ! tail -1 < /tmp/hco | grep FAIL
do
    /bin/nc -l -p 1888 -c "/ezbin/health_check_http.sh"
done