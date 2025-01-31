#!/bin/sh

set -e

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh --dry-run
sudo systemctl start docker
rm get-docker.sh
