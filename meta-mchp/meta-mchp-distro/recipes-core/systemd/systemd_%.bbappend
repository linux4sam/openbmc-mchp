require ${@bb.utils.contains('MCHP_FEATURES', 'mchp-strip-systemd', '${BPN}-strip-mchp.inc', '', d)}

#Ensure systemd-modules-load is enabled
PACKAGECONFIG:append:pn-systemd = " kmod"
