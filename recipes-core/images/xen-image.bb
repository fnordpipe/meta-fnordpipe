SUMMARY = "xen hypervisor image"
LICENSE = "MIT"

IMAGE_FEATURES += "package-management"

inherit core-image

IMAGE_INSTALL += " \
  packagegroup-diskutils \
  packagegroup-fnordpipe-cli \
  packagegroup-xen \
  "
