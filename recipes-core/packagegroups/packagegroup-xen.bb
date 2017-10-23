SUMMARY = "xen software stack with additions"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
  xen-xencommons \
  xen-xenstored \
  xen-xendomains \
  bridge-utils \
  "
