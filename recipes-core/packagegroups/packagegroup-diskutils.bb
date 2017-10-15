SUMMARY = "diskutils for raid, lvm and crypto management"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
  cryptsetup \
  lvm2 \
  lvm2-scripts \
  lvm2-udevrules \
  mdadm \
  syslinux-extlinux \
  locky-core \
  "
