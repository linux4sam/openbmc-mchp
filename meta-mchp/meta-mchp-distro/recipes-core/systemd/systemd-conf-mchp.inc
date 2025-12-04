FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://99-custom-journald.conf \
"

FILES:${PN} += " \
    ${sysconfdir}/systemd/journald.conf.d/ \
"

do_install:append () {
    install -D -m0644 ${WORKDIR}/99-custom-journald.conf ${D}${sysconfdir}/systemd/journald.conf.d/99-custom-journald.conf
}
