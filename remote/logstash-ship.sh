#!/bin/bash

cd /root/logstash-forwarder

cat > config.json <<EOF
{
  # The network section covers network configuration :)
  "network": {
    # A list of downstream servers listening for our messages.
    # logstash-forwarder will pick one at random and only switch if
    # the selected one appears to be dead or unresponsive
    "servers": [ "logstash.$(cat /var/easydeploy/share/.config/project).$(cat /var/easydeploy/share/.config/deploy_env).comp.ezd:12345" ],

    # Network timeout in seconds. This is most important for
    # logstash-forwarder determining whether to stop waiting for an
    # acknowledgement from the downstream server. If an timeout is reached,
    # logstash-forwarder will assume the connection or server is bad and
    # will connect to a server chosen at random from the servers list.
    "timeout": 15
  },

  # The list of files configurations
  "files": [
    # An array of hashes. Each hash tells what paths to watch and
    # what fields to annotate on events from those paths.
    {
      "paths": [
        "/var/log/messages",
        "/var/log/*.log"
      ],

      # A dictionary of fields to annotate on each event.
      "fields": {
         "component" : "$(cat /var/easydeploy/share/.config/component)",
         "env" : "$(cat /var/easydeploy/share/.config/deploy_env)",
         "hostname" :"$(cat /var/easydeploy/share/.config/hostname)"
      }
    }, {
      "paths": [
        "/var/log/easydeploy/run*.log"
      ],

      # A dictionary of fields to annotate on each event.
      "fields": {
         "type":"ezd",
         "component" : "$(cat /var/easydeploy/share/.config/component)",
         "env" : "$(cat /var/easydeploy/share/.config/deploy_env)",
         "hostname" :"$(cat /var/easydeploy/share/.config/hostname)"
      }
    }, {
      "paths": [
        "/var/easydeploy/share/log/*.logstash.txt.log"
      ],

      # A dictionary of fields to annotate on each event.
      "fields": {
         "type":"app",
         "component" : "$(cat /var/easydeploy/share/.config/component)",
         "env" : "$(cat /var/easydeploy/share/.config/deploy_env)",
         "hostname" :"$(cat /var/easydeploy/share/.config/hostname)"
      }
    }
  ]
}
EOF


./logstash-forwarder -config config.json
