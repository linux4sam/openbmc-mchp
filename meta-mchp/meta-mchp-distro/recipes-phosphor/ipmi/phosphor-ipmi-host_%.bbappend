FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://master-write-read-white_list.json"

do_install:append() {
    install -d ${D}${datadir}/phosphor-ipmi-host
    install -m 0644 ${WORKDIR}/master-write-read-white_list.json ${D}${datadir}/phosphor-ipmi-host/
}
