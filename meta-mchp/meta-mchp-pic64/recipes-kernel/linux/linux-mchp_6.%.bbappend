FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:pic64gx-curiosity-kit = " file://overlays.cfg \
                                         file://sensors_io_uring.cfg \
                                         file://disable_mpfs_watchdog.cfg \
                                       "

do_assemble_fitimage[depends] = "${@'dt-overlay-mchp:do_deploy' \
                                  if "pic64gx-curiosity-kit" in d.getVar('MACHINE') \
                                  else ''}"

addtask deploy after do_install
