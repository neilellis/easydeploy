#!/bin/bash -eu
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

error() {
    echo "**** EASYDEPLOY-COMPONENT-INSTALL-FAILED ****"
   sourcefile=$1
   lineno=$2
   code=$3
   echo "$1:$2" $3
   set +e
   exit $3
}

function dockerfileExtensions() {
    while read line
    do
        command=$(echo $line | cut -d" " -f1)
        case "$command" in
        MOD) bash /home/easydeploy/modules/$(echo $line | sed 's/^MOD[\\t ]*//g') ;;
        *) echo "$line";;
        esac
    done

}
cd /home/easydeploy/deployment
git clean -df
git checkout -- .
cp -f ~/.ssh/id_rsa  id_rsa
cp -f ~/.ssh/id_rsa.pub  id_rsa.pub
cat Dockerfile | dockerfileExtensions > Dockerfile.processed
mv -f  Dockerfile Dockerfile.orig
mv -f  Dockerfile.processed Dockerfile
docker build --no-cache=true -t $(cat /var/easydeploy/share/.config/component) .
retval=$?
rm Dockerfile
mv -f Dockerfile.orig Dockerfile
exit $retval

