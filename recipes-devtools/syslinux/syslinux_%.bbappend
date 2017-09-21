inherit deploy

FILESEXTRAPATHS_prepend := "${THISDIR}/syslinux:"

SRC_URI += " \
	file://syslinux.cfg \
	"

do_deploy() {
  install -d ${DEPLOYDIR}/syslinux-${PV}
  install -m 644 ${B}/bios/mbr/mbr.bin ${DEPLOYDIR}/syslinux-${PV}/mbr.bin
  install -m 644 ${B}/bios/mbr/gptmbr.bin ${DEPLOYDIR}/syslinux-${PV}/gptmbr.bin
  install -m 644 ${B}/bios/core/ldlinux.sys ${DEPLOYDIR}/syslinux-${PV}/ldlinux.sys
  install -m 644 ${B}/bios/com32/elflink/ldlinux/ldlinux.c32 ${DEPLOYDIR}/syslinux-${PV}/ldlinux.c32
  install -m 644 ${B}/bios/com32/lib/libcom32.c32 ${DEPLOYDIR}/syslinux-${PV}/libcom32.c32
  install -m 644 ${B}/bios/com32/mboot/mboot.c32 ${DEPLOYDIR}/syslinux-${PV}/mboot.c32

  install -m 644 ${WORKDIR}/syslinux.cfg ${DEPLOYDIR}/syslinux-${PV}/syslinux.cfg
}

addtask deploy after do_populate_sysroot do_packagedata
