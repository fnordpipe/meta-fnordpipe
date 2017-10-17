DESCRIPTION = "luks decryption daemon"
LICENSE = "MIT"
HOMEPAGE = "https://github.com/esno/locky"
LIC_FILES_CHKSUM = "file://LICENSE;md5=818a1914937100fe15c345e88ef19245"

DEPENDS += " \
  openssl \
  cryptsetup \
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
  file://locky.service \
  file://luksd.service \
  file://luksd-hook.service \
  file://luksd-hook.sh \
  "

PACKAGES = " \
  ${PN}-core \
  ${PN}-luksd \
  ${PN}-dbg \
  "

FILES_${PN}-core += " \
  ${bindir}/locky \
  ${systemd_system_unitdir}/locky.service \
  "

FILES_${PN}-luksd += " \
  ${bindir}/luksd \
  ${bindir}/luksd-hook \
  ${systemd_system_unitdir}/luksd.service \
  ${systemd_system_unitdir}/luksd-hook.service \
  "

FILES_${PN}-dbg += " \
  ${bindir}/.debug \
  "

inherit useradd systemd

SYSTEMD_PACKAGES = "${PN}-core ${PN}-luksd"
SYSTEMD_SERVICE_${PN}-core = "locky.service"
SYSTEMD_SERVICE_${PN}-luksd = " \
  luksd.service \
  luksd-hook.service \
  "

USERADD_PACKAGES = "${PN}-core"
USERADD_PARAM_${PN}-core = "-u 942 -U -d /dev/null -r -s /bin/false locky"

do_install() {
  install -d ${D}/${bindir}
  install -m 0755 ${S}/locky ${D}/${bindir}
  install -m 0755 ${S}/luksd ${D}/${bindir}
  install -m 0755 ${WORKDIR}/luksd-hook.sh ${D}/${bindir}/luksd-hook

  install -d ${D}/${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/locky.service ${D}/${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/luksd.service ${D}/${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/luksd-hook.service ${D}/${systemd_system_unitdir}
}
