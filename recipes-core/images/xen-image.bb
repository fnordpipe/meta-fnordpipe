SUMMARY = "xen hypervisor image"
LICENSE = "MIT"

IMAGE_CLASSES += "image_types_release"
IMAGE_FSTYPES += " release"

IMAGE_FEATURES += " \
  package-management \
  read-only-rootfs \
  "

inherit core-image

require fnordpipe.inc

IMAGE_INSTALL += " \
  packagegroup-core-ssh-dropbear \
  packagegroup-diskutils \
  packagegroup-fnordpipe-cli \
  packagegroup-xen \
  "

genfstab() {
  install -d ${IMAGE_ROOTFS}/usr/local/system
  cat >> ${IMAGE_ROOTFS}/etc/fstab << EOF
LABEL=BOOT /boot ext4 defaults 0 0
none /etc/systemd/network aufs br=/boot/config/network:/etc/systemd/network,x-systemd.requires=/boot 0 0
EOF
}

disable_services() {
  rm -f ${IMAGE_ROOTFS}/etc/systemd/system/multi-user.target.wants/xendomains.service
  rm -f ${IMAGE_ROOTFS}/etc/systemd/system/sockets.target.wants/dropbear.socket
}

ROOTFS_POSTPROCESS_COMMAND += "genfstab; disable_services; "
