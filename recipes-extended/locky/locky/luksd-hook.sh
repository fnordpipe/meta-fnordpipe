#!/bin/sh

LUKS_NAME=${LUKS_NAME:-luks0}

while [ ! -f /dev/mapper/${LUKS_NAME} ]; do
  sleep 1
done

vgchange -ay
mount /dev/mapper/vg0-dom0 /usr/local/system
systemctl stop systemd-networkd.service
systemctl stop systemd-resolved.service
umount /etc/systemd/network
mount -t aufs \
  -o br=/usr/local/system/etc/systemd/network:/etc/systemd/network \
  /etc/systemd/network
mount -t aufs \
  -o br=/usr/local/system/root:/root \
  /root
mount -t aufs \
  -o br=/usr/local/system/dropbear:/etc/dropbear \
  /etc/dropbear
systemctl start systemd-networkd.service
systemctl start systemd-resolved.service
systemctl start dropbear.service
systemctl start xendomains.service
