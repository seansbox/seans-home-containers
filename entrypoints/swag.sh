#!/bin/sh

# Write the Cloudflare API token to the configuration file
echo "dns_cloudflare_api_token = ${FLARE_TOKEN}" > "/config/dns-conf/cloudflare.ini"

# Get the list of services for SWAG proxy configuration
services="${SWAG_SERVICES}"

# Remove existing proxy configuration files
rm /config/nginx/proxy-confs/*.conf 2>/dev/null

# Loop through each service and create its proxy configuration
for service in $services; do
  cp "/config/nginx/proxy-confs/${service}.subdomain.conf.sample" "/config/nginx/proxy-confs/${service}.subdomain.conf"
done

# Dynamically set the site title using PUB_DOMAIN
site_title="${PUB_DOMAIN%%.*}"

# Generate HTML content using the site title
cat <<EOF > /config/www/index.html
<!DOCTYPE html>
<html>
<head>
  <title>${site_title}</title>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200"/>
  <style>
    body { margin: 0; background: black; color: white; display: flex; justify-content: center; align-items: center; height: 100vh; width: 100vw; padding: 10vh 10vw; box-sizing: border-box; }
    .material-symbols-outlined { font-size: 80vh; }
  </style>
</head>
<body>
  <span class="material-symbols-outlined">package_2</span>
</body>
</html>
EOF

# Remove any existing resolver configuration
rm -f /config/nginx/resolver.conf

# Execute the command passed in CMD
exec "$@"
