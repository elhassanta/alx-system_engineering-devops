#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Update package repositories and install HAProxy
apt-get update
apt-get install -y haproxy

# Configure HAProxy
cat <<EOL > /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend main
    bind *:80
    default_backend web_servers

backend web_servers
    balance roundrobin
    server web-01 ubuntu 34.229.49.127:80 check
    server web-02 ubuntu 54.173.120.12:80 check
EOL

# Enable HAProxy as a service
systemctl enable haproxy
systemctl restart haproxy

# Inform the user that the setup is complete
echo "HAProxy is configured and running. Traffic will be distributed to web-01 and web-02 using a round-robin algorithm."

