inherit deploy

do_deploy() {
  install -d ${DEPLOYDIR}/syslinux
  install -m 644 ${B}/bios/mbr/mbr.bin ${DEPLOYDIR}/syslinux/mbr-${PV}.bin
  install -m 644 ${B}/bios/mbr/gptmbr.bin ${DEPLOYDIR}/syslinux/gptmbr-${PV}.bin
}

addtask deploy after do_populate_sysroot do_packagedata
