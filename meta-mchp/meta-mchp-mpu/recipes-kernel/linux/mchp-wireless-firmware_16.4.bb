SUMMARY = "Microchip WILC devices firmware files for use with Linux kernel"
SECTION = "kernel"
LICENSE = "MICROCHIP_FW"

LIC_FILES_CHKSUM = "file://LICENSE.wilc_fw;beginline=6;md5=e1a0446d046c966a27276cf8e728f687"

SRCREV = "1e5bff41ab3993301763379668e38d0c2817a7e6"
SRC_URI = "git://github.com/linux4wilc/firmware.git;protocol=https;branch=master"
S = "${WORKDIR}/git"

inherit allarch

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/mchp/
    cp -r ${S}/* ${D}${nonarch_base_libdir}/firmware/mchp/

    # remove unneeded file
    rm -f ${D}${nonarch_base_libdir}/firmware/mchp/README.md
    rm -f ${D}${nonarch_base_libdir}/firmware/mchp/LICENSE.wilc_fw
    chmod -x ${D}${nonarch_base_libdir}/firmware/mchp/*
}

FILES:${PN} += " \
    ${nonarch_base_libdir}/firmware/mchp/wilc*.bin \
    "

# TODO: use ALTERNATIVE like in "linux-firmware" package
