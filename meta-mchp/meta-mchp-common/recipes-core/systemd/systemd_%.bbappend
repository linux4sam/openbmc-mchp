FILESEXTRAPATHS:prepend := "${THISDIR}/systemd-journald:${THISDIR}/${PN}:"
SRC_URI:append = " file://systemd-journald-override.conf"

#Ensure systemd-modules-load is enabled
PACKAGECONFIG:append:pn-systemd = " kmod"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/journald.conf.d
    install -m 0644 ${WORKDIR}/systemd-journald-override.conf ${D}${sysconfdir}/systemd/journald.conf.d/override.conf
    echo "Contents of ${D}${sysconfdir}/systemd/journald.conf.d/:"
    ls -l ${D}${sysconfdir}/systemd/journald.conf.d/
}

