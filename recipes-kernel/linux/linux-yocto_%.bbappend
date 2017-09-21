FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
  file://broadcom-net.scc \
  "

COMPATIBLE_MACHINE_amd64 = "amd64"

KMACHINE_amd64 = "amd64"
KBRANCH_amd64 = "standard/base"
