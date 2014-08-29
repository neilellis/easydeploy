#!/bin/bash -eux

if /ezbin/health_check.sh  > /tmp/hco
then
    /bin/echo -ne 'HTTP/1.1 200 OK\r\n\r\n' && exit 0
else
    /bin/echo -ne 'HTTP/1.1 500 FAIL\r\n\r\n' && exit 1
fi

