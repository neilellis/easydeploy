while /ezbin/health_check.sh
do
 nc -l -p 1888 -c "/ezbin/health_check.sh"
done