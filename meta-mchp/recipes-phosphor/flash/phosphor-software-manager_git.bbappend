FILESEXTRAPATHS:prepend := "${THISDIR}/phosphor-software-manager:"
SRC_URI:append = " file://0001-obmc-flash-bmc-mchp-by-label.patch"

# Pin SRCREV to ensure the patch applies to the correct version.
# NOTE:
# - This assignment overrides any SRCREV set in the base recipe or included .inc file
#   (e.g., meta-phosphor/recipes-phosphor/flash/phosphor-software-manager.inc).
# - The build will always use this specific git commit, regardless of changes upstream.
# - If the SRCREV in the base recipe or .inc file changes and synchronization with upstream is desired,
#   both this SRCREV and the patch must be updated to match the new source version.
SRCREV = "b7df12ccaaebb649e02a767212adccf2d38120c5"

# Add e2fsprogs to the build to include tune2fs
DEPENDS += "e2fsprogs"

# Ensure the tune2fs tool is included in the runtime dependencies
RDEPENDS_${PN} += "e2fsprogs-tune2fs"

do_install:append() {
    # Substitute @MMC_DEV@ with the value from MMC_DEV in the installed script
    sed -i "s|@MMC_DEV@|${MMC_DEV}|g" ${D}${bindir}/obmc-flash-bmc
}

do_install[vardeps] += "MMC_DEV"