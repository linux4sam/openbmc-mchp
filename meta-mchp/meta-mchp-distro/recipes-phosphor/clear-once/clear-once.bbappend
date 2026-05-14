FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_install:append() {
    # Correct the path of fw_setenv and remove the duplicate ExecStart line
    sed -i 's|/sbin/fw_setenv|/usr/bin/fw_setenv|g' ${D}${systemd_system_unitdir}/clear-once.service
    sed -i '0,/ExecStart=\/usr\/bin\/fw_setenv openbmconce/{/ExecStart=\/usr\/bin\/fw_setenv openbmconce/d;}' ${D}${systemd_system_unitdir}/clear-once.service
}

# Ensure the service file is installed correctly
FILES:${PN} += "${systemd_system_unitdir}/clear-once.service"

