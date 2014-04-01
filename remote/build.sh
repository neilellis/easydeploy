#!/bin/bash
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
~/bin/update-components.sh
cd /home/easydeploy/deployment
cat Dockerfile | dockerfileExtensions > Dockerfile.processed
mv -f  Dockerfile Dockerfile.orig
mv -f  Dockerfile.processed Dockerfile
docker build --no-cache=true -t $(cat /var/easydeploy/share/.config/component) .
retval=$?
rm Dockerfile
mv -f Dockerfile.orig Dockerfile
exit $retval

