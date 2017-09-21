SUMMARY = "xen hypervisor image"
LICENSE = "MIT"

IMAGE_FEATURES += " \
  package-management \
  read-only-rootfs \
  "

inherit core-image

IMAGE_INSTALL += " \
  packagegroup-core-ssh-dropbear \
  packagegroup-diskutils \
  packagegroup-fnordpipe-cli \
  packagegroup-xen \
  "

fstab_aufs() {
  cat >> ${IMAGE_ROOTFS}/etc/fstab << EOF
none /etc/systemd/network aufs br=/boot/config/network:/etc/systemd/network 0 0
EOF
}

#ROOTFS_POSTPROCESS_COMMAND += "fstab_aufs; "
