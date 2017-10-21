inherit image_types

RELEASE_ROOTFS_TYPE = "cpio.gz"
RELEASE_XEN = "$(realpath ${DEPLOY_DIR_IMAGE}/xen-${MACHINE}.gz)"
RELEASE_KERNEL = "$(realpath ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE})"
RELEASE_ROOTFS = "${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${RELEASE_ROOTFS_TYPE}"
RELEASE_DEPLOY_IMAGE = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.boot.tar.gz"

IMAGE_TYPEDEP_release = "${RELEASE_ROOTFS_TYPE}"

DEPENDS += " \
  coreutils-native \
  "

RELEASE_WORKDIR = "${WORKDIR}/release"

IMAGE_CMD_release() {
  install -d \
    ${RELEASE_WORKDIR} \
    ${RELEASE_WORKDIR}/syslinux \
    ${RELEASE_WORKDIR}/config \
    ${RELEASE_WORKDIR}/config/network

  install \
    ${RELEASE_XEN} \
    ${RELEASE_KERNEL} \
    ${RELEASE_ROOTFS} \
    ${RELEASE_WORKDIR}

  ln -sf \
    $(basename ${RELEASE_XEN}) \
    ${RELEASE_WORKDIR}/xen.gz

  ln -sf \
    $(basename ${RELEASE_KERNEL}) \
    ${RELEASE_WORKDIR}/kernel

  ln -sf \
    $(basename ${RELEASE_ROOTFS}) \
    ${RELEASE_WORKDIR}/rootfs.cpio.gz

  echo "DEFAULT teapot" > ${RELEASE_WORKDIR}/syslinux/syslinux.cfg
  echo "" >> ${RELEASE_WORKDIR}/syslinux/syslinux.cfg
  echo "LABEL teapot" >> ${RELEASE_WORKDIR}/syslinux/syslinux.cfg
  echo "  KERNEL /mboot.c32" >> ${RELEASE_WORKDIR}/syslinux/syslinux.cfg
  echo "  APPEND /xen.gz dom0_mem=4096M dom0_max_vcpus=2 --- /kernel quiet --- /rootfs.cpio.gz" >> ${RELEASE_WORKDIR}/syslinux/syslinux.cfg

  tar czf ${RELEASE_DEPLOY_IMAGE} \
    -C ${RELEASE_WORKDIR} .
}
