DESCRIPTION = "initrd script for on-the-fly installation"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=818a1914937100fe15c345e88ef19245"

SRC_URI = " \
  file://LICENSE \
  file://initrd-install.sh \
  file://initrd-install.service \
  "

RDEPENDS_${PN} = " \
  cryptsetup \
  e2fsprogs \
  gptfdisk \
  gzip \
  lvm2 \
  mdadm \
  parted \
  syslinux-extlinux \
  tar \
  wget \
  "

inherit systemd

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "initrd-install.service"

S = "${WORKDIR}"

do_install() {
  install -d ${D}/${libexecdir}/
  install -m 0754 ${S}/initrd-install.sh ${D}/${libexecdir}

  install -d ${D}/${systemd_system_unitdir}
  install -m 0644 ${S}/initrd-install.service ${D}/${systemd_system_unitdir}
}
