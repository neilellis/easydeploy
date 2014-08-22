#!/bin/bash -eux
/ezbin/health_check.sh > /tmp/hco
while  ! grep FAIL < /tmp/hco
do
  nc -l -p 1888 -c "(/ezbin//health_check.sh > /tmp/hco && cat /tmp/hco) || exit 1"
done