.PHONY: help start restart update vpn deps

SERVICES := $(shell awk '/^[[:space:]]+[a-zA-Z0-9_-]+:/ {gsub(/:.*/,""); gsub(/^[[:space:]]+/,""); if ($$1 != "x-common-settings") print $$1}' docker-compose.yaml)
IMAGES   := $(shell awk '/^[[:space:]]+image:/ {gsub(/"/,""); gsub(/:latest$$/,""); print $$2}' docker-compose.yaml | sort -u)

help:
	@awk '/^[a-zA-Z0-9][^:=#]*:([^=]|$$)/ { sub(/:.*/, "", $$1); print $$1 }' $(MAKEFILE_LIST) | sort | uniq

start:
	sudo docker compose up -d --remove-orphans

restart:
	sudo docker compose up -d --remove-orphans --force-recreate --build

update:
	@set -e; \
	for img in $(IMAGES); do \
		sudo docker pull "$$img"; \
	done
	sudo docker image prune -f
	sudo docker compose up --force-recreate --build -d --remove-orphans

vpn:
	sudo docker exec -i gluetun wget -qO- https://am.i.mullvad.net/connected
	sudo docker exec -i qbittorrent wget -qO- https://am.i.mullvad.net/connected

deps:
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt-get install -y curl
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh ./get-docker.sh --dry-run
	sudo systemctl start docker
	rm -f get-docker.sh
