#!/bin/bash -eux
/ezbin/health_check.sh > /tmp/hco
while  ! tail -1 < /tmp/hco | grep FAIL
do
    /bin/nc.traditional -l -p 1888 -c "/ezbin/health_check.sh  > /tmp/hco && (/bin/echo -e 'HTTP/1.1 200 OK\r\n\r\n') || (/bin/echo -e 'HTTP/1.1 500 FAIL\r\n\r\n' && exit -1)"
done