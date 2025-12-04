inherit image_types_phosphor

FLASH_EXT4_BASETYPE ?= "ext4"
IMAGE_TYPES += " mchp-sd"
IMAGE_TYPES_MASKED += " mchp-sd"
IMAGE_TYPEDEP:mchp-sd = "${FLASH_EXT4_BASETYPE}"

# Bespoke task to create boot vfat partition
do_generate_mchp_sd_boot_partition() {
    set -e

    BOOTIMG="${WORKDIR}/boot.vfat"
    BOOTSIZE=16  # Size in MB, hardcoded to match wks
    bbwarn "BOOT_PARTITION_SIZE_MB is ${BOOT_PARTITION_SIZE_MB}"

    # Create empty file of 16MB
    dd if=/dev/zero of=${BOOTIMG} bs=1M count=${BOOTSIZE}

    # Make it a VFAT filesystem
    mkfs.vfat -n boot-a -F 16 ${BOOTIMG}

    # Prepare mtools config to point to the image
    export MTOOLS_SKIP_CHECK=1
    echo "drive z: file=\"${BOOTIMG}\"" > ${WORKDIR}/mtools.conf
    export MTOOLSRC=${WORKDIR}/mtools.conf

    # Copy each file in IMAGE_BOOT_FILES
    for f in ${IMAGE_BOOT_FILES}; do
        src="${DEPLOY_DIR_IMAGE}/$f"
        if [ ! -e "$src" ]; then
            echo "ERROR: $src not found!"
            exit 1
        fi
        mcopy -i ${BOOTIMG} "$src" ::/
    done

    zstd -f -k -T0 -c ${ZSTD_COMPRESSION_LEVEL} ${BOOTIMG} > image-kernel
}
do_generate_mchp_sd_boot_partition[dirs] = " ${S}/ext4"
do_generate_mchp_sd_boot_partition[depends] += "dosfstools-native:do_populate_sysroot mtools-native:do_populate_sysroot zstd-native:do_populate_sysroot u-boot:do_deploy virtual/kernel:do_deploy"

do_generate_mchp_sd_rofs_partition() {
    set -e

    if [ -z "${ROFS_PARTITION_SIZE_MB}" ]; then
        bbfatal "ROFS_PARTITION_SIZE_MB is not set in the configuration."
    fi
    bbwarn "ROFS_PARTITION_SIZE_MB is ${ROFS_PARTITION_SIZE_MB}"

    TARGET_SIZE=$(expr ${ROFS_PARTITION_SIZE_MB} \* 1024 \* 1024)
    BLOCK_SIZE=4096
    INODE_COUNT=8192
    BLOCK_COUNT=$(expr ${ROFS_PARTITION_SIZE_MB} \* 256)

    IMAGE_PATH="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.${FLASH_EXT4_BASETYPE}"
    NEW_IMAGE_PATH="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.cleaned.${FLASH_EXT4_BASETYPE}"

    if [ ! -f "${IMAGE_PATH}" ]; then
        bbfatal "Input image ${IMAGE_PATH} does not exist."
    fi

    # Create the ext4 image file directly, letting mkfs.ext4 create a sparse file
    mkfs.ext4 -F -b $BLOCK_SIZE -N $INODE_COUNT -T small "${NEW_IMAGE_PATH}" $BLOCK_COUNT

    TMPDIR_ORIG=$(mktemp -d)
    set +e
    # Suppress rdump "Operation not permitted" messages
    debugfs -R "rdump / ${TMPDIR_ORIG}" "${IMAGE_PATH}" > /dev/null 2>&1
    set -e

    # Remove any existing /boot directory and create an empty one
    [ -d "${TMPDIR_ORIG}/boot" ] && rm -rf "${TMPDIR_ORIG}/boot"
    mkdir -p "${TMPDIR_ORIG}/boot"

    if [ "$(ls -A "${TMPDIR_ORIG}")" = "" ]; then
        rm -rf "${TMPDIR_ORIG}"
        return 0
    fi

    cd "${TMPDIR_ORIG}"

    # Suppress debugfs "Allocated inode" and other output
    find . -type d | sort | while read d; do
        if [ "$d" != "." ]; then
            debugfs -w -R "mkdir \"/${d#./}\"" "${NEW_IMAGE_PATH}" > /dev/null 2>&1 || true
        fi
    done

    find . -type f | while read f; do
        debugfs -w -R "write \"$f\" \"/${f#./}\"" "${NEW_IMAGE_PATH}" > /dev/null 2>&1 || true
    done

    find . -type l | while read l; do
        LINK_TARGET=$(readlink "$l")
        debugfs -w -R "symlink \"/${l#./}\" \"$LINK_TARGET\"" "${NEW_IMAGE_PATH}" > /dev/null 2>&1 || true
    done

    cd -
    rm -rf "${TMPDIR_ORIG}"

    # Run e2fsck and minimize fs
    # e2fsck returns 1 if it fixes errors, which is not fatal
    e2fsck -fy "${NEW_IMAGE_PATH}" > /dev/null 2>&1 || [ $? -eq 1 ]
    resize2fs -M "${NEW_IMAGE_PATH}" > /dev/null 2>&1
    MIN_BLOCKS=$(resize2fs -P "${NEW_IMAGE_PATH}" 2>/dev/null | awk '{print $7}')
    MIN_SIZE_BYTES=$(expr $MIN_BLOCKS \* $BLOCK_SIZE)
    if [ "$MIN_SIZE_BYTES" -gt "$TARGET_SIZE" ]; then
        bbfatal "Minimum filesystem size ($MIN_SIZE_BYTES bytes) exceeds target size ($TARGET_SIZE bytes)."
    fi

    resize2fs "${NEW_IMAGE_PATH}" $(expr $TARGET_SIZE / $BLOCK_SIZE)
    e2fsck -fy "${NEW_IMAGE_PATH}"

    # Compress the new image
    bbnote "Compressing the cleaned ext4 image using zstd..."
    zstd -f -k -T0 -c ${ZSTD_COMPRESSION_LEVEL} "${NEW_IMAGE_PATH}" > ${IMAGE_LINK_NAME}.${FLASH_EXT4_BASETYPE}.zst

    # Create a symbolic link to the compressed image
    ln -sf ${IMAGE_LINK_NAME}.${FLASH_EXT4_BASETYPE}.zst image-rofs
}
do_generate_mchp_sd_rofs_partition[dirs] = " ${S}/ext4"
do_generate_mchp_sd_rofs_partition[depends] += " \
    zstd-native:do_populate_sysroot \
    ${PN}:do_image_${FLASH_EXT4_BASETYPE} \
    virtual/kernel:do_deploy \
    u-boot:do_deploy \
    openssl-native:do_populate_sysroot \
    phosphor-hostfw-image:do_deploy \
"
do_generate_mchp_sd_rofs_partition[cleandirs] = ""
do_generate_mchp_sd_rofs_partition[nostamp] = "1"

do_generate_mchp_sd_rwfs_partition() {
    set -e

    if [ -z "${RWFS_PARTITION_SIZE_MB}" ]; then
        bbfatal "RWFS_PARTITION_SIZE_MB is not set in the configuration."
    fi
    bbwarn "RWFS_PARTITION_SIZE_MB is ${RWFS_PARTITION_SIZE_MB}"

    TARGET_SIZE=$(expr ${RWFS_PARTITION_SIZE_MB} \* 1024 \* 1024)
    BLOCK_SIZE=4096
    INODE_COUNT=8192
    BLOCK_COUNT=$(expr ${RWFS_PARTITION_SIZE_MB} \* 256)

    IMAGE_PATH="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.rwfs.${FLASH_EXT4_OVERLAY_BASETYPE}"
    NEW_IMAGE_PATH="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.rwfs.cleaned.${FLASH_EXT4_OVERLAY_BASETYPE}"

    if [ ! -f "${IMAGE_PATH}" ]; then
        bbfatal "Input image ${IMAGE_PATH} does not exist."
    fi

    # Create the ext4 image file directly, letting mkfs.ext4 create a sparse file
    mkfs.ext4 -F -b $BLOCK_SIZE -N $INODE_COUNT -T small "${NEW_IMAGE_PATH}" $BLOCK_COUNT

    TMPDIR_ORIG=$(mktemp -d)
    set +e
    debugfs -R "rdump / ${TMPDIR_ORIG}" "${IMAGE_PATH}" > /dev/null 2>&1
    set -e

    [ -d "${TMPDIR_ORIG}/boot" ] && rm -rf "${TMPDIR_ORIG}/boot"

    if [ "$(ls -A "${TMPDIR_ORIG}")" = "" ]; then
        rm -rf "${TMPDIR_ORIG}"
        return 0
    fi

    cd "${TMPDIR_ORIG}"

    find . -type d | sort | while read d; do
        if [ "$d" != "." ]; then
            debugfs -w -R "mkdir \"/${d#./}\"" "${NEW_IMAGE_PATH}" > /dev/null 2>&1 || true
        fi
    done

    find . -type f | while read f; do
        debugfs -w -R "write \"$f\" \"/${f#./}\"" "${NEW_IMAGE_PATH}" > /dev/null 2>&1 || true
    done

    find . -type l | while read l; do
        LINK_TARGET=$(readlink "$l")
        debugfs -w -R "symlink \"/${l#./}\" \"$LINK_TARGET\"" "${NEW_IMAGE_PATH}" > /dev/null 2>&1 || true
    done

    cd -
    rm -rf "${TMPDIR_ORIG}"

    # Run e2fsck and minimize fs
    # e2fsck returns 1 if it fixes errors, which is not fatal
    e2fsck -fy "${NEW_IMAGE_PATH}" > /dev/null 2>&1 || [ $? -eq 1 ]
    resize2fs -M "${NEW_IMAGE_PATH}" > /dev/null 2>&1
    MIN_BLOCKS=$(resize2fs -P "${NEW_IMAGE_PATH}" 2>/dev/null | awk '{print $7}')
    MIN_SIZE_BYTES=$(expr $MIN_BLOCKS \* $BLOCK_SIZE)
    if [ "$MIN_SIZE_BYTES" -gt "$TARGET_SIZE" ]; then
        bbfatal "Minimum filesystem size ($MIN_SIZE_BYTES bytes) exceeds target size ($TARGET_SIZE bytes)."
    fi

    resize2fs "${NEW_IMAGE_PATH}" $(expr $TARGET_SIZE / $BLOCK_SIZE)
    e2fsck -fy "${NEW_IMAGE_PATH}"

    # Compress the new image
    bbnote "Compressing the cleaned ext4 rwfs image using zstd..."
    zstd -c -T0 -c ${ZSTD_COMPRESSION_LEVEL} "${NEW_IMAGE_PATH}" > "${IMAGE_LINK_NAME}.rwfs.${FLASH_EXT4_OVERLAY_BASETYPE}.zst"

    # Create a symbolic link to the compressed image
    ln -sf "${IMAGE_LINK_NAME}.rwfs.${FLASH_EXT4_OVERLAY_BASETYPE}.zst" image-rwfs
}
do_generate_mchp_sd_rwfs_partition[dirs] = " ${S}/ext4"
do_generate_mchp_sd_rwfs_partition[depends] += " \
    zstd-native:do_populate_sysroot \
    ${PN}:do_image_${FLASH_EXT4_OVERLAY_BASETYPE} \
    openssl-native:do_populate_sysroot \
    phosphor-hostfw-image:do_deploy \
"
do_generate_mchp_sd_rwfs_partition[cleandirs] = ""
do_generate_mchp_sd_rwfs_partition[nostamp] = "1"

do_generate_mchp_sd_rest() {
    echo "PWD at start of $FUNCNAME: $PWD"
    ls -l

    touch image-u-boot
    ln -sf ${S}/MANIFEST MANIFEST
    ln -sf ${S}/publickey publickey

    make_signatures image-u-boot image-kernel image-rofs image-rwfs MANIFEST publickey
    make_tar_of_images update.sd MANIFEST publickey ${signature_files}
}
do_generate_mchp_sd_rest[dirs] = " ${S}/ext4"
do_generate_mchp_sd_rest[depends] += " \
    openssl-native:do_populate_sysroot \
    tar-native:do_populate_sysroot \
    ${SIGNING_KEY_DEPENDS} \
    ${PN}:do_copy_signing_pubkey \
    phosphor-hostfw-image:do_deploy \
"

# Add the custom task to the image build process if mchp-sd is in IMAGE_FSTYPES
# Order:
# do_generate_rwfs_ext4
# do_generate_phosphor_manifest
# do_generate_mchp_sd_boot_partition
# do_generate_mchp_sd_rofs_partition
# do_generate_mchp_sd_rest
# do_image_complete
python() {
    types = d.getVar('IMAGE_FSTYPES').split()
    if 'mchp-sd' in types:
        bb.build.addtask('do_generate_rwfs_ext4', 'do_generate_phosphor_manifest', '', d)
        bb.build.addtask('do_generate_phosphor_manifest', 'do_generate_mchp_sd_boot_partition', 'do_generate_rwfs_ext4', d)
        bb.build.addtask('do_generate_mchp_sd_boot_partition', 'do_generate_mchp_sd_rofs_partition', 'do_generate_phosphor_manifest', d)
        bb.build.addtask('do_generate_mchp_sd_rofs_partition', 'do_generate_mchp_sd_rwfs_partition', 'do_generate_mchp_sd_boot_partition', d)
        bb.build.addtask('do_generate_mchp_sd_rwfs_partition', 'do_generate_mchp_sd_rest', 'do_generate_mchp_sd_rofs_partition', d)
        bb.build.addtask('do_generate_mchp_sd_rest', 'do_image_complete', 'do_generate_mchp_sd_rwfs_partition', d)
}