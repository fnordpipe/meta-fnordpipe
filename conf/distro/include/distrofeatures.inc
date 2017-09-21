DISTRO_FEATURES_append += " \
  systemd \
  xen \
  "

DISTRO_FEATURES_remove = " \
  3g \
  alsa \
  bluetooth \
  irda \
  nfs \
  opengl \
  pulseaudio \
  zeroconf \
  wayland \
  wifi \
  x11 \
  "

DISTRO_FEATURES_BACKFILL_CONSIDERED = " \
  pulseaudio \
  "

VIRTUAL-RUNTIME_init_manager = "systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED = "sysvinit"
