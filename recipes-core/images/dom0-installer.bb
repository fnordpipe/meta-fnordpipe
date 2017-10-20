SUMMARY = "xen dom0 installer"
LICENSE = "MIT"

IMAGE_FEATURES += " \
  read-only-rootfs \
  "

inherit core-image

IMAGE_INSTALL += " \
  initrd-install \
  "

genfstab() {
  cat >> ${IMAGE_ROOTFS}/etc/fstab << EOF
LABEL=BOOT /boot ext4 defaults 0 0
/boot/config/hostname /etc/hostname none defaults,bind,x-systemd.requires=/boot 0 0
none /etc/systemd/network aufs br=/boot/config/network:/etc/systemd/network,x-systemd.requires=/boot 0 0
EOF
}

ROOTFS_POSTPROCESS_COMMAND += "genfstab; "
