#!/bin/bash -eux
iptables -t nat -D OUTPUT -p tcp --dport 1888 -j REDIRECT --to-port 80
iptables -t nat -D PREROUTING -p tcp --dport 1888 -j REDIRECT --to-port 80