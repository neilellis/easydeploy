
set +u
if [ -n "$DO_BASE_IMAGE_NAME" ]  && [ -z "$DO_BASE_IMAGE" ]
then
    export DO_BASE_IMAGE=$(tugboat info_image -n $DO_BASE_IMAGE_NAME | grep ID: | cut -d: -f2  | tr -d ' ' | tail -1)
fi
set -u

dataCenters=( "nyc2:4" "nyc1:1" "ams1:2" "sfo1:3" "ams2:5" "sgp1:6" "lon1:7" "nyc3:8")

for dataCenter in "${dataCenters[@]}"
do
    KEY="${dataCenter%%:*}"
    VALUE="${dataCenter##*:}"
    [[ $KEY == $DATACENTER ]] && export DO_REGION=${VALUE}  || :
done

alias tugboat="./tugboat_retry.sh"

