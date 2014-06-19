#!/bin/bash -eu
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/easydeploy/bin:/root/bin

update=false
release=false
src_branch=
dest_branch=$(cat /var/easydeploy/share/.config/branch)
if (( $# > 0 ))
then
    if [[ "$1" == "update" ]]
    then
        update=true
    fi
    if [[ "$1" == "release" ]]
    then
        release=true
        src_branch=$2
    fi
fi

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
if [[ $update == "true" ]]  || [[ $release == "true" ]]
then
    git pull
fi
if [[ $release == "true" ]]
then
    git checkout ${dest_branch}
    git pull
    git merge origin/${src_branch}
fi
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

