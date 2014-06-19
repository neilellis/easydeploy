#!/bin/bash
cat > /etc/logstash.conf <<EOF
input {
  file {
  add_field => {
    component => "$(cat /var/easydeploy/share/.config/component)"
    env =>  "$(cat /var/easydeploy/share/.config/deploy_env)"
    hostname => "$(cat /var/easydeploy/share/.config/hostname)"
    severity => ""
    }

    type => "syslog"
    path => [ "/var/log/messages", "/var/log/syslog" ]
  }
  file {
  add_field => {
    component => "$(cat /var/easydeploy/share/.config/component)"
    env =>  "$(cat /var/easydeploy/share/.config/deploy_env)"
    hostname => "$(cat /var/easydeploy/share/.config/hostname)"
    severity => ""
    }

    type => "ezd"
    path => [ "/var/log/easydeploy/run*.log" ]
  }
  file {
  add_field => {
    component => "$(cat /var/easydeploy/share/.config/component)"
    env =>  "$(cat /var/easydeploy/share/.config/deploy_env)"
    hostname => "$(cat /var/easydeploy/share/.config/hostname)"
    severity => ""
    }

    type => "app-json"
    codec => "json"
    path => [ "/var/easydeploy/share/log/*.logstash.json.log" ]
  }
  file {
  add_field => {
    component => "$(cat /var/easydeploy/share/.config/component)"
    env =>  "$(cat /var/easydeploy/share/.config/deploy_env)"
    hostname => "$(cat /var/easydeploy/share/.config/hostname)"
    severity => ""
    }

    type => "app"
    path => [ "/var/easydeploy/share/log/*.logstash.txt.log" ]
  }
}

output {
    tcp     { type => "linux"
              port => "7007"
              mode => client
              host => "logstash.$(cat /var/easydeploy/share/.config/project).$(cat /var/easydeploy/share/.config/deploy_env).comp.ezd"
    }

}

EOF
exec /usr/local/logstash/bin/logstash agent -f /etc/logstash.conf
