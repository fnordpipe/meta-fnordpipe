SUMMARY = "rescue image"
LICENSE = "MIT"

inherit core-image

require fnordpipe.inc

IMAGE_INSTALL += " \
  packagegroup-core-ssh-dropbear \
  packagegroup-rescue-tools \
  "
