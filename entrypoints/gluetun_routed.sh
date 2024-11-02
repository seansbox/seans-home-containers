#!/bin/sh

# Calculate VPN_GATEWAY and NET_GATEWAY from LAN and LAN_GATEWAY
VPN_GATEWAY="${LAN}.${GLUETUN}"
NET_GATEWAY="${LAN}.${LAN_GATEWAY}"

# Delete the default route
ip route del default

# Continuously attempt to set the default route via VPN_GATEWAY
until ip route | grep -q "default via $VPN_GATEWAY"; do
  ip route add default via "$VPN_GATEWAY"
  sleep 5
done

# Add specific routes for private networks via NET_GATEWAY
ip route add 10.0.0.0/8 via "$NET_GATEWAY"
ip route add 172.16.0.0/12 via "$NET_GATEWAY"
ip route add 192.168.0.0/16 via "$NET_GATEWAY"

# Execute the main command
exec "$@"
