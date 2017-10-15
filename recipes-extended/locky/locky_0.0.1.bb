DESCRIPTION = "luks decryption daemon"
LICENSE = "MIT"
HOMEPAGE = "https://github.com/esno/locky"
LIC_FILES_CHKSUM = "file://LICENSE;md5=818a1914937100fe15c345e88ef19245"

DEPENDS += " \
  openssl \
  cryptsetup \
  "

PACKAGES = " \
  ${PN}-core \
  ${PN}-luksd \
  ${PN}-dbg \
  "

FILES_${PN}-core += " \
  ${bindir}/locky \
  "

FILES_${PN}-luksd += " \
  ${bindir}/luksd \
  "

FILES_${PN}-dbg += " \
  ${bindir}/.debug \
  "

RDEPENDS_locky-core += " \
  libssl \
  ${PN}-luksd \
  "

RDEPENDS_locky-luksd += " \
  cryptsetup \
  "

SRC_URI[md5sum] = "1693323c3ba99feef92942029d7c5346"
SRC_URI[sha256sum] = "267a4e5021dd06c8b416a52ebd8b9fa5d60c8fd8f09e186fdea9af05679077b6"

SRC_URI = " \
  https://github.com/esno/locky/archive/v${PV}.tar.gz \
  "

do_install() {
  install -d ${D}/${bindir}
  install -m 0755 ${S}/locky ${D}/${bindir}
  install -m 0755 ${S}/luksd ${D}/${bindir}
}
