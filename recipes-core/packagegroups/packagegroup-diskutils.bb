SUMMARY = "diskutils for raid, lvm and crypto management"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
  mdadm \
  lvm2 \
  lvm2-scripts \
  lvm2-udevrules \
  cryptsetup \
  "
