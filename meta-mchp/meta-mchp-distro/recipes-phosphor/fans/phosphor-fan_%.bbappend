FILESEXTRAPATHS:prepend := "${THISDIR}/phosphor-fan:"

SRC_URI:append = " file://10-fansensor-deps.conf"

do_install:append() {
    install -d ${D}${systemd_unitdir}/system/phosphor-fan-control@.service.d
    install -m 0644 ${WORKDIR}/10-fansensor-deps.conf \
        ${D}${systemd_unitdir}/system/phosphor-fan-control@.service.d/10-fansensor-deps.conf
}

FILES:${PN}-control += "${systemd_unitdir}/system/phosphor-fan-control@.service.d/"