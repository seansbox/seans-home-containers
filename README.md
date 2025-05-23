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

  - It looks easier, but there are challenges (e.g. overlapping ports, shared hostnames, need for DNS aliases, etc.)
  - Creating small custom entrypoints for router/routed is pretty straight-forward and reusable
  - All containers look and act the same regarding networking, for a more consistent experience

## Testing

    # Check if various containers can all see eachother (across gluetun-routed and non)
    sudo docker exec -i swag ping -c 1 qbittorrent
    sudo docker exec -i swag ping -c 1 radarr
    sudo docker exec -i radarr ping -c 1 flaresolverr
    # See if your media mounted correctly
    sudo docker exec -it qbittorrent ls /data
    # Check if gluetun is connected to VPN
    sudo docker exec -i gluetun wget -qO- https://am.i.mullvad.net/connected
    # Check if qbittorrent is connected to VPN
    sudo docker exec -i qbittorrent wget -qO- https://am.i.mullvad.net/connected
    # Check if swag is NOT connected to VPN
    sudo docker exec -i swag wget -qO- https://am.i.mullvad.net/connected
    # Print out all custom files for debugging
    for file in .env docker-compose.yaml entrypoints/*; do echo "=== $file ==="; cat "$file"; echo; done

## Mount Notes (EXFAT)

    sudo apt update
    sudo apt install exfatprogs

    sudo fdisk /dev/sdb
    sudo mkfs.exfat /dev/sdb1

    # Figuring out the device info
    lsblk -o NAME,FSTYPE,UUID,MOUNTPOINT,SIZE
    sudo blkid

    # Adding the mount to fstab
    sudo nano /etc/fstab
    # <file system> <mount point> <type> <options> <dump> <pass>
    UUID=66C9-E45D /media/sean/Media25 exfat noauto,x-systemd.automount,nofail,umask=000 0 2
    UUID=77DE-F780 /media/sean/Media26 exfat noauto,x-systemd.automount,nofail,umask=000 0 2
    UUID=679C-D726 /media/sean/Media2TB exfat noauto,x-systemd.automount,nofail,umask=000 0 2

    # Mount test
    systemctl daemon-reload
    sudo mount -a
    sudo reboot
    df -h

## Mount Notes (BTRFS)

### Install BTRFS

    sudo apt update
    sudo apt install btrfs-progs btrfsmaintenance

### Check the devices

    lsblk -o NAME,MODEL,ROTA,SCHED,PHY-SeC,LOG-SeC /dev/sda
    lsblk -o NAME,MODEL,ROTA,SCHED,PHY-SeC,LOG-SeC /dev/sdb
    lsblk -o NAME,MODEL,ROTA,SCHED,PHY-SeC,LOG-SeC /dev/sde

### Wipe out the devices (careful!!!)

    sudo wipefs -a /dev/sda
    sudo wipefs -a /dev/sdb
    sudo wipefs -a /dev/sde
    sudo mkfs.btrfs -m raid1 -d raid1 /dev/sda /dev/sdb /dev/sde

### Mount the devices

    sudo mkdir -p /mnt/storage
    sudo chown -R sean:sean /mnt/storage
    sudo blkid /dev/sda
    sudo nano /etc/fstab
    UUID=your-uuid-here /mnt/storage btrfs defaults,compress=zstd 0 0

    sudo mount /mnt/storage

### Setup BTRFS scrubbing

    sudo systemctl enable btrfs-scrub.timer
    sudo systemctl start btrfs-scrub.timer
    sudo btrfs scrub start -Bd /mnt/storage

### Check the devices

    sudo btrfs filesystem show
    sudo btrfs filesystem df /mnt/storage
    sudo btrfs filesystem usage /mnt/storage
    sudo btrfs device stats /mnt/storage

### Test the compression

    dd if=/dev/zero of=/mnt/storage/testfile bs=1M count=100
    sync
    sudo btrfs filesystem du -s /mnt/storage/testfile

### Add/Remove devices

    sudo btrfs device add /dev/sdf /mnt/storage
    sudo btrfs balance start /mnt/storage
    sudo btrfs device remove /dev/sda /mnt/storage

## Mullvad Notes

- https://github.com/qdm12/gluetun/discussions/805#discussioncomment-2026642
