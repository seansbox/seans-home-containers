# seans-home-containers

## Setup

    cp sample.env .env
    nano .env
    docker compose up -d

## Questions

- Why not 'network_mode: host'?

  - Host-based containers often have overlapping ports, e.g. 80/443, 8080, 5353, etc.
  - mDNS is borderline impossible to get setup on containers otherwise (avahi, libnss, reflectors, etc.)
  - Containers that 'require' host mode can't tell when in macvlan and still function fine
  - Macvlan gives us control over which host network interface is exposed (e.g. wired and not wireless)
  - Come on, you have enough LAN IPs, just do it...

- Why not 'service:gluetun'?

  - It looks easier, but there are challenges (e.g. overlapping ports, shared hostnames, need for aliases, etc.)
  - Creating small custom entrypoints for router/routed is actualy pretty straight-forward and reusable
  - All containers look and act the same regarding networking, for a more consistent experience

## Testing

    # Check if various containers can all see eachother (across gluetun-routed and non)
    sudo docker exec -i swag ping -c 1 qbittorrent
    sudo docker exec -i swag ping -c 1 radarr
    sudo docker exec -i radarr ping -c 1 flaresolverr
    # Check if gluetun is connected to VPN
    sudo docker exec -i gluetun wget -qO- https://am.i.mullvad.net/connected
    # Check if qbittorrent is connected to VPN
    sudo docker exec -i qbittorrent wget -qO- https://am.i.mullvad.net/connected
    # Check if swag is NOT connected to VPN
    sudo docker exec -i swag wget -qO- https://am.i.mullvad.net/connected
    # Print out all custom files for debugging
    for file in .env docker-compose.yaml entrypoints/*; do echo "=== $file ==="; cat "$file"; echo; done
