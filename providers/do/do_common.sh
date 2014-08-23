
dataCenters=( "nyc2:4" "nyc1:1" "ams1:2" "sfo1:3" "ams2:5" "sgp1:6" "lon1:7" "nyc3:8")

for dataCenter in "${dataCenters[@]}"
do
    KEY="${dataCenter%%:*}"
    VALUE="${dataCenter##*:}"
    [[ $KEY == $DATACENTER ]] && export DO_REGION=${VALUE}  || :
done
