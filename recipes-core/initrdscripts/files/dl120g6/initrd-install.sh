#!/bin/sh

set -e

VERSION="0.0.1"
MACHINE="dl120g6"

DEV_LIST="${DEV_LIST:-/dev/sda /dev/sdb /dev/sdc /dev/sdd}"

LUKS_KEY=${LUKS_KEY:-fnordpipe}
LUKS_NAME=${LUKS_NAME:-luks0}
VG_NAME=${VG_NAME:-luks0vg0}
LV_NAME=${LV_NAME:-system}
HOST_NAME=${HOST_NAME:-install.nohost}

# usage: prepareDisk <device>
prepareDisks() {
  disk="${1}"

  sgdisk --zap-all ${disk}

  # ef02  bios boot partition
  # fd00  linux raid
  sgdisk -n 0:0:+1G -t 0:ef02 ${disk}
  sgdisk -n 0:0:0 -t 0:fd00 ${disk}

  # 2     legacy bios bootable
  sgdisk -A 1:set:2 ${disk}

  dd \
    if=/usr/share/syslinux/gptmbr.bin \
    of=${disk} \
    bs=440 \
    conv=notrunc \
    count=1
}

main() {
  hostname ${HOST_NAME}

  mkdir /tmp/installer
  cp -r \
    /boot/config/public.key.pem \
    /boot/config/root.key.pub \
    /boot/config/network \
    /tmp/installer

  umount /etc/systemd/network /boot

  md0devices=""
  md1devices=""
  for disk in ${DEV_LIST}; do
    prepareDisks ${disk}
    md0devices="${md0devices} ${disk}1"
    md1devices="${md1devices} ${disk}2"
  done
  partprobe

  mdadm --create /dev/md0 --level=1 \
    --metadata=1.0 --raid-devices=4 \
    ${md0devices}

  mdadm --create /dev/md1 --level=5 \
    --raid-devices=4 \
    ${md1devices}

  echo "${LUKS_KEY}" > /tmp/installer/luks0.key

  cryptsetup luksFormat /dev/md1 \
    -c aes-xts-plain64:sha512 \
    -s 512 -h sha256 \
    --key-file /tmp/installer/luks0.key

  cryptsetup luksOpen /dev/md1 ${LUKS_NAME} \
    --key-file /tmp/installer/luks0.key

  pvcreate /dev/mapper/${LUKS_NAME}
  vgcreate /dev/mapper/${LUKS_NAME} ${VG_NAME}
  lvcreate -L5G -n ${LV_NAME} ${VG_NAME}

  mkfs.ext4 -L "BOOT" /dev/md0
  mkfs.ext4 /dev/mapper/${VG_NAME}-${LV_NAME}

  mkdir /mnt/boot /mnt/system
  mount /dev/mapper/${VG_NAME}-${LV_NAME} /mnt/system
  mount /dev/md0 /mnt/boot

  mkdir /mnt/boot/syslinux
  extlinux --raid --install /mnt/boot/syslinux

  install \
    /usr/share/syslinux/{ldlinux.c32,libcom32.c32,mboot.c32} \
    /mnt/boot/syslinux

  wget -O /tmp/installer/os.tar.gz https://github.com/fnordpipe/meta-fnordpipe/releases/download/v${VERSION}/${MACHINE}.tar.gz
  tar xzf /tmp/installer/os.tar.gz -C /mnt/boot

  install -d /mnt/system/dropbear
  install -d /mnt/system/root
  install -m 0700 /mnt/system/root/.ssh
  install -d /mnt/system/systemd
  install -d /mnt/system/xen

  cp -r \
    /tmp/installer/public.key.pem \
    /tmp/installer/network \
    /mnt/boot/config

  install -m 0600 \
    /tmp/installer/root.key.pub \
    /mnt/system/root/.ssh/authorized_keys

  echo ${HOST_NAME} > /mnt/boot/config/hostname

  echo "LUKS_BLKDEV=/dev/disk/by-id/md-name-${HOST_NAME}:1" > /mnt/boot/config/hw.env
  echo "LUKS_NAME=${LUKS_NAME}" >> /mnt/boot/config/hw.env
  echo "VG_NAME=${VG_NAME}" >> /mnt/boot/config/hw.env
  echo "LV_NAME=${LV_NAME}" >> /mnt/boot/config/hw.env
  echo "PUBKEY=/boot/config/public.key.pem" >> /mnt/boot/config/hw.env

  reboot
}

main
