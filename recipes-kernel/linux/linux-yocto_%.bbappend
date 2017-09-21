FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

COMPATIBLE_MACHINE_dl120g6 = "dl120g6"

KMACHINE_dl120g6 = "dl120g6"
KBRANCH_dl120g6 = "standard/base"

SRC_URI_append_dl120g6 = " \
  file://dl120g6.scc \
  "
