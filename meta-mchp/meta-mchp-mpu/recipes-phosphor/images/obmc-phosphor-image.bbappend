inherit image_types_mchp

# WKS mmcblk substitution
python do_prepare_wks() {
    import os

    # Find the .wks.in template in BBPATH
    src = bb.utils.which(d.getVar('BBPATH'), 'scripts/lib/wic/canned-wks/sdimage-obmc.wks.in')
    if not src or not os.path.exists(src):
        bb.fatal("Could not find scripts/lib/wic/canned-wks/sdimage-obmc.wks.in in BBPATH")

    # Write the output to the same directory as the template
    dst = os.path.join(os.path.dirname(src), 'sdimage-obmc.wks')

    # Get variables from the build environment
    mmc_dev = d.getVar('MMC_DEV')
    boot_size_mb = d.getVar('BOOT_PARTITION_SIZE_MB')
    rofs_size_mb = d.getVar('ROFS_PARTITION_SIZE_MB')
    rwfs_size_mb = d.getVar('RWFS_PARTITION_SIZE_MB')

    # Validate required variables
    if not mmc_dev:
        bb.fatal("MMC_DEV variable is not set")
    if not boot_size_mb or not rofs_size_mb or not rwfs_size_mb:
        bb.fatal("Partition size variables (BOOT_PARTITION_SIZE_MB, ROFS_PARTITION_SIZE_MB, RWFS_PARTITION_SIZE_MB) are not set")

    # Read the template file
    with open(src, 'r') as f:
        content = f.read()

    # Replace placeholders with actual values
    content = content.replace('@MMC_DEV@', mmc_dev)
    content = content.replace('@BOOT_PARTITION_SIZE_MB@', boot_size_mb)
    content = content.replace('@ROFS_PARTITION_SIZE_MB@', rofs_size_mb)
    content = content.replace('@RWFS_PARTITION_SIZE_MB@', rwfs_size_mb)

    # Write the updated content to the destination file
    with open(dst, 'w') as f:
        f.write(content)
}
addtask do_prepare_wks before do_image_wic

# /Boot fstab line if not already existing
python do_rootfs:append() {
    import os
    import re

    fstab_path = os.path.join(d.getVar('IMAGE_ROOTFS'), 'etc', 'fstab')
    label_line = r'^LABEL=boot-a\s+/boot\s+vfat'

    # Read the file if it exists
    try:
        with open(fstab_path, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        lines = []

    # Check if the line exists
    found = any(re.search(label_line, line) for line in lines)

    # If not found, append the line
    if not found:
        with open(fstab_path, 'a') as f:
            f.write('LABEL=boot-a  /boot  vfat  defaults  0  2\n')
}

