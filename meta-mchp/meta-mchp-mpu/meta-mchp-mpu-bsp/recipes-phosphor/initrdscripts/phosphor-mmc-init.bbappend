FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://mmc-init-nogpt.sh"

do_install:append() {
    rm -f ${D}/init
    sed "s|@MMC_DEV@|${MMC_DEV}|g" ${UNPACKDIR}/mmc-init-nogpt.sh > ${WORKDIR}/mmc-init-nogpt.sh.subst
    install -m 0755 ${WORKDIR}/mmc-init-nogpt.sh.subst ${D}/init
}

do_install[vardeps] += "MMC_DEV"