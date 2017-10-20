#!/bin/sh

set -e

LUKS_NAME=${LUKS_NAME:-luks0}
VG_NAME=${VG_NAME:-luks0vg0}
LV_NAME=${LV_NAME:-system}

while [ ! -b /dev/mapper/${LUKS_NAME} ]; do
  sleep 1
done

vgchange -ay ${VG_NAME}
mount /dev/mapper/${VG_NAME}-${LV_NAME} /usr/local/system
systemctl stop systemd-networkd.service
systemctl stop systemd-resolved.service
umount /etc/systemd/network
mount -t aufs \
  -o br=/usr/local/system/systemd/network:/etc/systemd/network \
  /etc/systemd/network
mount -t aufs \
  -o br=/usr/local/system/root:/root \
  /root
mount -t aufs \
  -o br=/usr/local/system/dropbear:/etc/dropbear \
  /etc/dropbear
mount -t aufs \
  -o br=/usr/local/system/etc/xen:/etc/xen \
  /etc/xen
systemctl start systemd-networkd.service
systemctl start systemd-resolved.service
systemctl start dropbear.service
systemctl start xendomains.service
