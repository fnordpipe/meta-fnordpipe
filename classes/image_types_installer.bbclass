inherit image_types

INSTALLER_ROOTFS_TYPE = "cpio.gz"
INSTALLER_KERNEL = "$(realpath ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE})"
INSTALLER_ROOTFS = "${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${INSTALLER_ROOTFS_TYPE}"
INSTALLER_DEPLOY_IMAGE = "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.img.xz"

IMAGE_TYPEDEP_installer = "${INSTALLER_ROOTFS_TYPE}"

IMAGE_DEPENDS_installer += " \
  coreutils-native \
  dosfstools-native \
  mtools-native \
  parted-native \
  syslinux-native \
  virtual/bootloader \
  virtual/kernel \
  xz-native \
  "

INSTALLER_WORKDIR = "${WORKDIR}/installer"

IMAGE_CMD_installer() {
  install -d \
    ${INSTALLER_WORKDIR} \

  BOOTFS_SIZE=$(du -bks ${INSTALLER_ROOTFS} | awk '{print $1}')
  KERNEL_SIZE=$(du -bks ${INSTALLER_KERNEL} | awk '{print $1}')
  IMG_SIZE=$(expr ${KERNEL_SIZE} + ${BOOTFS_SIZE} + 8192)

  dd if=/dev/zero of=${INSTALLER_WORKDIR}/${IMAGE_NAME}.img \
    bs=1024 count=0 seek=${IMG_SIZE}

  parted -s ${INSTALLER_WORKDIR}/${IMAGE_NAME}.img mklabel msdos
  parted -s ${INSTALLER_WORKDIR}/${IMAGE_NAME}.img mkpart primary fat32 8192B 100%
  parted -s ${INSTALLER_WORKDIR}/${IMAGE_NAME}.img set 1 boot on

  echo "DEFAULT installer" > ${INSTALLER_WORKDIR}/syslinux.cfg
  echo "" >> ${INSTALLER_WORKDIR}/syslinux.cfg
  echo "LABEL installer" >> ${INSTALLER_WORKDIR}/syslinux.cfg
  echo "  KERNEL /kernel" >> ${INSTALLER_WORKDIR}/syslinux.cfg
  echo "  INITRD /rootfs.cpio.gz" >> ${INSTALLER_WORKDIR}/syslinux.cfg
  echo "  APPEND quiet" >> ${INSTALLER_WORKDIR}/syslinux.cfg

  echo 'DEV_LIST="/dev/sda /dev/sdb /dev/sdc /dev/sdd"' > ${INSTALLER_WORKDIR}/install.env
  echo 'LUKS_KEY="fnordpipe"' >> ${INSTALLER_WORKDIR}/install.env
  echo 'LUKS_NAME="luks0"' >> ${INSTALLER_WORKDIR}/install.env
  echo 'VG_NAME="luks0vg0"' >> ${INSTALLER_WORKDIR}/install.env
  echo 'LV_NAME="system"' >> ${INSTALLER_WORKDIR}/install.env
  echo 'HOST_NAME="installed.nohost"' >> ${INSTALLER_WORKDIR}/install.env

  BOOT_BLOCKS=$(LC_ALL=C parted -s ${INSTALLER_WORKDIR}/${IMAGE_NAME}.img unit b print | awk '/ 1 / {print substr($4, 1, length($4 - 1)) / 512 / 2}')
  rm -f ${INSTALLER_WORKDIR}/boot.img 2> /dev/null
  mkfs.vfat -F 32 -n "BOOT" -S 512 -C ${INSTALLER_WORKDIR}/boot.img ${BOOT_BLOCKS}

  export MTOOLS_SKIP_CHECK=1
  MTOOLS_SKIP_CHECK=1 mmd -i ${INSTALLER_WORKDIR}/boot.img ::/config
  MTOOLS_SKIP_CHECK=1 mmd -i ${INSTALLER_WORKDIR}/boot.img ::/config/network
  MTOOLS_SKIP_CHECK=1 mmd -i ${INSTALLER_WORKDIR}/boot.img ::/syslinux

  MTOOLS_SKIP_CHECK=1 mcopy -i ${INSTALLER_WORKDIR}/boot.img -s ${INSTALLER_KERNEL} ::/kernel
  MTOOLS_SKIP_CHECK=1 mcopy -i ${INSTALLER_WORKDIR}/boot.img -s ${INSTALLER_ROOTFS} ::/rootfs.cpio.gz
  MTOOLS_SKIP_CHECK=1 mcopy -i ${INSTALLER_WORKDIR}/boot.img -s ${INSTALLER_WORKDIR}/syslinux.cfg ::/syslinux/syslinux.cfg
  MTOOLS_SKIP_CHECK=1 mcopy -i ${INSTALLER_WORKDIR}/boot.img -s ${INSTALLER_WORKDIR}/install.env ::/config/install.env

  syslinux --directory /syslinux --install ${INSTALLER_WORKDIR}/boot.img

  dd if=${INSTALLER_WORKDIR}/boot.img of=${INSTALLER_WORKDIR}/${IMAGE_NAME}.img \
    conv=notrunc seek=1 bs=8192

  dd if=${DEPLOY_DIR_IMAGE}/syslinux/gptmbr.bin of=${INSTALLER_WORKDIR}/${IMAGE_NAME}.img \
    bs=440 conv=notrunc count=1 

  xz -c ${INSTALLER_WORKDIR}/${IMAGE_NAME}.img > ${INSTALLER_DEPLOY_IMAGE}
}
