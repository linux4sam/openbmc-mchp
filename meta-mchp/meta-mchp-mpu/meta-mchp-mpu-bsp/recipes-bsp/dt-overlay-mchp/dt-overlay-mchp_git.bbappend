inherit mchp-compat-machines

do_prepare_zimage_symlink() {
    bbnote "Preparing zImage symlink in ${DEPLOY_DIR_IMAGE} for mkimage"
    ZIMAGE_INITRAMFS="${DEPLOY_DIR_IMAGE}/zImage-initramfs-${MACHINE}.bin"
    ZIMAGE="${DEPLOY_DIR_IMAGE}/zImage"
    if [ -e "${ZIMAGE_INITRAMFS}" ]; then
        ln -sf "${ZIMAGE_INITRAMFS}" "${ZIMAGE}"
        bbnote "Symlinked ${ZIMAGE} -> ${ZIMAGE_INITRAMFS}"
    else
        bbwarn "Source image not found: ${ZIMAGE_INITRAMFS}"
    fi
}
addtask prepare_zimage_symlink before do_compile after do_fetch
do_prepare_zimage_symlink[dirs] = "${DEPLOY_DIR_IMAGE}"
do_prepare_zimage_symlink[depends] += "virtual/kernel:do_deploy"
