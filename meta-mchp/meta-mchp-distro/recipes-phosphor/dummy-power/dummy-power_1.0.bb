SUMMARY = "Dummy OpenBMC Power Control D-Bus Service"
DESCRIPTION = "Provides a dummy /org/openbmc/control/power0 object and org.openbmc.control.Power service for boards with no power control hardware."
LICENSE = "MICROCHIP"
LIC_FILES_CHKSUM = "file://${UNPACKDIR}/dummy_power.c;beginline=1;endline=23;md5=6931635b03bd32b3203a96934eb2f0f9"


SRC_URI = "file://dummy_power.c \
           file://dummy-power@.service \
          "

S = "${UNPACKDIR}"

DEPENDS = "systemd"

RDEPENDS:${PN} = ""

inherit systemd

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} ${DEBUG_PREFIX_MAP} dummy_power.c -lsystemd -o dummy_power
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 dummy_power ${D}${bindir}/dummy_power

    install -d ${D}${systemd_system_unitdir}
    # Call dummy-power service as expected by the openbmc power control
    install -m 0644 ${UNPACKDIR}/dummy-power@.service ${D}${systemd_system_unitdir}/org.openbmc.control.Power@.service
}

SYSTEMD_SERVICE:${PN} = "org.openbmc.control.Power@0.service"
SYSTEMD_AUTO_ENABLE = "enable"

FILES:${PN} += "${systemd_system_unitdir}/org.openbmc.control.Power@.service"



