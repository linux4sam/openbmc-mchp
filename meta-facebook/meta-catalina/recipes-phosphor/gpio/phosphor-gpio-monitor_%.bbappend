FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

inherit obmc-phosphor-systemd systemd

SRC_URI += " \
    file://catalina-gpio-monitor \
    file://prepare-serv-json \
    file://phosphor-multi-gpio-monitor.json \
    file://phosphor-multi-gpio-presence.json \
    file://phosphor-multi-gpio-monitor-evt.json \
    file://phosphor-multi-gpio-presence-evt.json \
    "

RDEPENDS:${PN}:append = " bash"

FILES:${PN} += "${systemd_system_unitdir}/*"

SYSTEMD_SERVICE:${PN}-monitor += " \
    assert-gpio-log@.service \
    assert-reset-button.service \
    assert-run-power-pg.service \
    deassert-reset-button.service \
    deassert-run-power-pg.service \
    "

SYSTEMD_AUTO_ENABLE = "enable"

do_install:append:() {
    install -d ${D}${datadir}/${PN}
    install -d ${D}${libexecdir}/${PN}

    install -m 0644 ${WORKDIR}/phosphor-multi-gpio-monitor.json \
                    ${D}${datadir}/${PN}/phosphor-multi-gpio-monitor.json
    install -m 0644 ${WORKDIR}/phosphor-multi-gpio-presence.json \
                    ${D}${datadir}/${PN}/phosphor-multi-gpio-presence.json
    install -m 0644 ${WORKDIR}/phosphor-multi-gpio-monitor.json \
                    ${D}${datadir}/${PN}/phosphor-multi-gpio-monitor-evt.json
    install -m 0644 ${WORKDIR}/phosphor-multi-gpio-presence.json \
                    ${D}${datadir}/${PN}/phosphor-multi-gpio-presence-evt.json
    install -m 0755 ${WORKDIR}/catalina-gpio-monitor ${D}${libexecdir}/${PN}/catalina-gpio-monitor
    install -m 0755 ${WORKDIR}/prepare-serv-json ${D}${libexecdir}/${PN}/prepare-serv-json
}
