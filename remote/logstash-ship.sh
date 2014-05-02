#!/bin/bash
cat > /etc/logstash.conf <<EOF
input {
  file {
  add_field => {
    component => "$(cat /var/easydeploy/share/.config/component)"
    env =>  "$(cat /var/easydeploy/share/.config/deploy_env)"
    host => "$(cat /var/easydeploy/share/.config/hostname)"
    }

    type => "syslog"
    path => [ "/var/log/messages", "/var/log/syslog", "/var/log/easydeploy/*.log" ]
  }
}

output {
    stdout {}
    tcp     { type => "linux"
              port => "7007"
              mode => client
              codec => multiline {
                pattern => "^\s"
                what => "previous"
            }
    }

}

EOF
/usr/local/logstash/bin/logstash agent -f /etc/logstash.conf
