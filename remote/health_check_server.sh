#!/bin/bash -eux
/ezbin/health_check.sh > /tmp/hco

function check() {
    if /ezbin/health_check.sh  > /tmp/hco
    then
        (/bin/echo -ne 'HTTP/1.1 200 OK\r\n\r\n')
    else
        (/bin/echo -ne 'HTTP/1.1 500 FAIL\r\n\r\n' && exit 1)
    fi
}

export -f check

while  ! tail -1 < /tmp/hco | grep FAIL
do
    /bin/nc.traditional -l -p 1888 -c "/bin/bash -eux check"
done