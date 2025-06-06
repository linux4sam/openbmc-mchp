DESCRIPTION = "Extra udev rules for Microchip boards"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-or-later;md5=fed54355545ffd980b814dab4a3b312c"

SRC_URI = " file://keyboard.rules"
SRC_URI:sam9x75 = " file://sam9x75/keyboard.rules"
SRC_URI:sama7d65 = " file://sama7d65/keyboard.rules"
SRC_URI:append:sama5d2 = " file://ptc.rules"

S = "${WORKDIR}"

do_install () {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/*.rules ${D}${sysconfdir}/udev/rules.d/
}

do_install:sam9x75 () {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/sam9x75/*.rules ${D}${sysconfdir}/udev/rules.d/
}

do_install:sama7d65 () {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/sama7d65/*.rules ${D}${sysconfdir}/udev/rules.d/
}
