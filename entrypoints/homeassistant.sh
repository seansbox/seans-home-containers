#!/bin/sh

CONFIG_FILE="/config/configuration.yaml"

if [ -f "$CONFIG_FILE" ] && ! grep -q "use_x_forwarded_for" "$CONFIG_FILE"; then
  cat <<EOF >> "$CONFIG_FILE"

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.0.0.0/8
    - 172.16.0.0/12
    - 192.168.0.0/16
EOF
  echo "Added HTTP configuration to $CONFIG_FILE."
fi

# Execute the command passed in CMD
exec "$@"
