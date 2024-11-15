SYSTEMD_SERVICE:${PN} = ""

do_install:append() {
    if [ -f ${D}${systemd_system_unitdir}/iptables.service ]; then
        mv ${D}${systemd_system_unitdir}/iptables.service ${D}${systemd_system_unitdir}/iptables.example.service
    fi
    if [ -f ${D}${systemd_system_unitdir}/ip6tables.service ]; then
        mv ${D}${systemd_system_unitdir}/ip6tables.service ${D}${systemd_system_unitdir}/ip6tables.example.service
    fi
}

FILES:${PN} += "${systemd_unitdir}"
FILES:${PN} += "${systemd_unitdir}/iptables.example.service"
FILES:${PN} += "${systemd_unitdir}/ip6tables.example.service"
