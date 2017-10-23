SUMMARY = "diskutils for raid, lvm and crypto management"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
  cryptsetup \
  e2fsprogs \
  gptfdisk \
  gzip \
  lvm2 \
  lvm2-scripts \
  lvm2-udevrules \
  mdadm \
  parted \
  syslinux-extlinux \
  syslinux-misc \
  tar \
  wget \
  "
