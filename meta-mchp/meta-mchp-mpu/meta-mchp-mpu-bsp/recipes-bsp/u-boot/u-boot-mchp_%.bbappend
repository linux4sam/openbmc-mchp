FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://envs/"
SRC_URI:append = " file://fw_env.config"
SRC_URI:append = " file://bootm-len.cfg"

inherit mchp-compat-machines

do_configure:append() {
    cat ${UNPACKDIR}/bootm-len.cfg >> ${S}/configs/${UBOOT_MACHINE}
}

PROVIDES += "u-boot"