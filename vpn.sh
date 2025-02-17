#!/bin/sh

set -e

sudo docker exec -i gluetun wget -qO- https://am.i.mullvad.net/connected
sudo docker exec -i qbittorrent wget -qO- https://am.i.mullvad.net/connected
