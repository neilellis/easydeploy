#!/bin/bash -eux
/ezbin/health_check.sh > /tmp/health_check_out
while  !  grep FAIL < /tmp/health_check_out
do
  nc -l -p 1888 -q 60 -c "/ezbin/health_check.sh > /tmp/health_check_out ; echo -e \"HTTP/1.1 200 OK\n\n $(</tmp/health_check_out)\""
done