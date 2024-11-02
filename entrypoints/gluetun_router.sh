#!/bin/sh

# Enable IP forwarding and set up iptables rules for routing traffic through the VPN

echo "Setting up Gluetun as a network router..."

# Allow forwarding of packets from eth0 to tun0
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT

# Allow established and related connections back from tun0 to eth0
iptables -A FORWARD -i tun0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Enable NAT (network address translation) for traffic going out through tun0
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

# Execute the original gluetun entrypoint to start the VPN service
exec "$@"
