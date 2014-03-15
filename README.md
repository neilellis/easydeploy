easydeploy
==========

A set of scripts that all incredibly easy deployment and running of apps using Docker and supervisord

## 1. Creating an easydeploy project

At present easydeploy only supports Ubuntu/git/Docker combination. So we start by creating a git project - on GitLab, GitHub or anywhere which allows for SSH based git access.

### The Configuration file ed.sh

This file should contain the following:

    export DOCKER_COMMANDS=
    export DOCKER_ARGS=
    export EASYDEPLOY_PORTS=
    export EASYDEPLOY_EXTERNAL_PORTS=
    export EASYDEPLOY_PROCESS_NUMBER=
    export EASYDEPLOY_PACKAGES=

All variables are optional and *must* be exported (all the scripts rely on that.

EASYDEPLOY_PORTS should be a space separated list of ports that should be mapped on the docker instance(s) so a value of "80 8080" translates to `-p 80:80 -p 8080:8080`

EASYDEPLOY_EXTERNAL_PORTS should be a space separated list of ports that should be open on the *host* machine.

EASYDEPLOY_PROCESS_NUMBER (misnamed) is the number of instances that should be run on each host.

DOCKER_ARGS (misnamed) is a set of options that are passed to docker before the name of the instance to run. Here you can do your own port mapping like "-p 80:8080" - but don't forget to expose the ports using EASYDEPLOY_EXTERNAL_PORTS

EASYDEPLOY_PACKAGES is a space seperated list of (apt-get) packages to deploy prior to the running of the install script.

EASYDEPLOY_STATE can be 'stateless' or 'stateful' the default behaviour is stateful, stateful services destroy all traces of their state on restarts using dockers `--rm=true` and by running `docker rm $(docker -q -a)` in the update.sh script.

EASYDEPLOY_UPDATE_CRON should be a cron pattern that will be used to run the update.sh script which updates your application on a regular basis set this to 'none' (the default) if you don't want the script run.

### The Dockerfile

This should be a normal Dockerfile.


## 2. Deploying it

### Deployment profile files

Again all variables should be exported, and here are the variables:

    #Specific
    export COMPONENT=logstash

    #Common
    export GIT_URL_HOST=git.cazcade.com
    export GIT_URL_USER=snapito
    export PROVIDER=do
    export USERNAME=root
    export DEPLOY_ENV=prod

    #Provider specific
    export DO_BASE_IMAGE=2158507
    export DO_KEYS=93676
    export DO_IMAGE_SIZE=62
    export DO_REGION=4

To understand these, let's look at where easydeploy downloads your project (from the previous section). As mentioned earlier we only support git and the git url will be built as follows


    git@${GIT_URL_HOST}:${GIT_URL_USER}/${COMPONENT}

The PROVIDER value will be used for the advanced scripts that include image creation and provisioning, let's skip that for now.

The USERNAME value is the username that easydeploy should use to log into the machine. This user must be root or have password-less sudo priviledges.

Finally the DEPLOY_ENV says which environment we're deploying too. This will also translate into a branch from git if the value is anything but the special values *prod* or *alt-prod*. It also is used as part of the naming system used by the provisioning scripts.

### Deploying

    ./deploy.sh <profile-file> <ip-or-hostname>

The first time the script is run it will create the eeasydeploy ssh keys and tell you the public key. You will need to use this public key to grant access to your git repository - and that is why it is always listed at the beginning of a deploy.

Once the keys are created this command will deploy your application to the hostname supplied - run it within a docker container and keep it running using supervisord


## 3. Runtime

### The host

As part of the deployment process a user called 'easydeploy' will be created on the host system. In the `/home/easydeploy` directory will be a bin directory containing scripts used by the easydeploy runtime.

#### run.sh

This is the script that is run by supervisord which then runs your docker container, this script should be run by the easydeploy user.

#### update.sh

This script triggers a new git pull and a complete rebuild of the docker container, then it reboots the host.


## 4. Cloud Functions

If you are using a supported cloud provider (currently Digital Ocean only) then you also can do some more dvanced functions.

### Upgrade Machines

    ./upgrade-machines.sh <profile-file>

This command will create a temporary machine, deploy to it, create a machine image and then use that image to re-image all the deployed servers that match the profile (on Digital Ocean we do that by matching the droplet name of ${DEPLOY_ENV}-${GIT_URL_USER}-${COMPONENT}).

Easydeploy will look for the variable PROVIDER in the profile file and use that to determine which scripts to run internally.

### Rebuild Machines

    ./rebuild-machines.sh <profile-file>

This is similar to Upgrade Machines, however instead it uses an existing machine image without creating a new one first.


## Watch this project, easydeploy is in it's infancy - but boy is it simple to use :) ##








