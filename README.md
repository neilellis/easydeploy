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

EASYDEPLOY_PORTS should be a space separated list of ports that should be mapped on the docker instance(s) so a value of "80 8080" translates to -p 80:80 -p 8080:8080

EASYDEPLOY_EXTERNAL_PORTS should be a space separated list of ports that should be open on the *host* machine.

EASYDEPLOY_PROCESS_NUMBER (misnamed) is the number of instances that should be run on each host.

DOCKER_ARGS (misnamed) is a set of options that are passed to docker before the name of the instance to run. Here you can do your own port mapping like "-p 80:8080" - but don't forget to expose the ports using EASYDEPLOY_EXTERNAL_PORTS

EASYDEPLOY_PACKAGES is a space seperated list of (apt-get) packages to deploy prior to the running of the install script.

### The Dockerfile

Thsis should be a normal Dockerfile.

AND THAT IS IT!!!


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

# Watch this project, easydeploy is in it's infancy - but boy is it simple to use :) #








