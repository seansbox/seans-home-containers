#!/bin/sh

set -e

# https://raw.githubusercontent.com/qdm12/gluetun/master/internal/storage/servers.json

sudo docker exec -i gluetun wget -qO- https://am.i.mullvad.net/connected
sudo docker exec -i qbittorrent wget -qO- https://am.i.mullvad.net/connected
