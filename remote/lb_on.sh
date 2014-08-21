#!/bin/bash -eux
iptables -t nat -A OUTPUT -p tcp --dport 1888 -j REDIRECT --to-port 80
iptables -t nat -A PREROUTING -p tcp --dport 1888 -j REDIRECT --to-port 80