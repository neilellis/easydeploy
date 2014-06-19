#!/bin/bash -eu

cd $(dirname $0) &> /dev/null
. common.sh


grace_period=30

function usage() {

    echo "release [-g <grace-period-in-seconds>] <src-env> <target-env>"
}

while getopts "hg:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         g)
             grace_period=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

shift $((OPTIND-1))
src_env=$1
shift
dest_env=$1
shift




function release_first() {
    dest_mc="$1"
    shift
    ssh  -o "StrictHostKeyChecking no" easyadmin@${dest_mc} "serf leave"
    echo "Machine has left project via Serf, ready to start upgrade after grace period"
    sleep ${grace_period}
    echo "Merging branch and rebuilding"
    ssh  -o "StrictHostKeyChecking no" easydeploy@${dest_mc} "/ezbin/build.sh release $src_env"
    echo "Restarting Docker container"
    ssh  -o "StrictHostKeyChecking no" easyadmin@${dest_mc} "sudo /ezbin/restart-component.sh"
    sleep ${grace_period}
    echo "Rejoining project via Serf"
    ssh  -o "StrictHostKeyChecking no" easyadmin@${dest_mc} "serf join $@"
}

function release_others() {
    dest_mc="$1"
    shift
    ssh  -o "StrictHostKeyChecking no" easyadmin@${dest_mc} "serf leave"
    echo "Machine has left project via Serf, ready to start upgrade after grace period"
    sleep ${grace_period}
    echo "Merging branch and rebuilding"
    ssh  -o "StrictHostKeyChecking no" easydeploy@${dest_mc} "/ezbin/build.sh update"
    echo "Restarting Docker container"
    ssh  -o "StrictHostKeyChecking no" easyadmin@${dest_mc} "sudo /ezbin/restart-component.sh"
    echo "Rejoining project via Serf"
    ssh  -o "StrictHostKeyChecking no" easyadmin@${dest_mc} "serf join $@"
}


dest_mc_name=$(mc_name_for_env ${dest_env})
src_mc_name=$(mc_name_for_env ${src_env})
src_machine=$(../providers/${PROVIDER}/list-machines-by-ip.sh ${src_mc_name} | tail -1)

if [[ -z  ${src_machine} ]]
then
    echo "No source machine available to use, have you created one?"
    exit -3
fi

echo "Testing src machine ${src_mc_name} (${src_machine}) before release."

if ssh  -o "StrictHostKeyChecking no" easyadmin@${src_machine} "sudo /ezbin/health_check.sh" > /tmp/ezd.health.check.${src_mc_name}
then
    echo "Source machine ${src_machine} is healthy"
else
    echo "Source machine ${src_machine} is unhealthy, release aborted."
    cat /tmp/ezd.health.check.${src_mc_name}
    exit -4
fi

function merge() {
    ssh -o StrictHostKeyChecking=no git@${GIT_URL_HOST}  /bin/bash  &> /dev/null</dev/null  || true
    dir=$(pwd)
    mkdir -p /tmp/ezd_release_checkout
    cd /tmp/ezd_release_checkout
    [ -d easydeploy-${COMPONENT} ] && rm -rf easydeploy-${COMPONENT}
    git clone git@${GIT_URL_HOST}:${GIT_URL_USER}/easydeploy-${COMPONENT}.git
    cd easydeploy-${COMPONENT}
    dest_branch=$(branch_for_env $dest_env)
    src_branch=$(branch_for_env $src_env)
    git checkout ${dest_branch}
    git pull
    git merge origin/${src_branch}
    git push

}

if [[ -z "${USE_PARALLEL}" ]]
then
    dest_mcs="$(../providers/${PROVIDER}/list-machines-by-ip.sh ${dest_mc_name} | tr '\n' ' ' | tr -s ' ')"
    first=true
    for dest_mc in ${dest_mcs}
    do
        if [[ $first == "true" ]]
        then
            release_first ${dest_mc} ${dest_mcs}
            if ssh  -o "StrictHostKeyChecking no" easyadmin@${dest_mc} "sudo /ezbin/health_check.sh" > /tmp/ezd.health.check.${dest_mc}
            then
                echo "Destination machine ${src_machine} is healthy after merge, merging locally and pushing."
                merge
                first=false
            else
                echo "Destination machine ${src_machine} is unhealthy, after merge release aborted."
                cat /tmp/ezd.health.check.${dest_mc}
                exit -5
            fi
        else
            release_others ${dest_mc} ${dest_mcs}
        fi
    done
else
    echo "Parallel releases not supported yet."
fi

