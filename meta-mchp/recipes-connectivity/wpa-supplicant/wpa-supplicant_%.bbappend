FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PACKAGECONFIG ??= "openssl"

SRC_URI:append = " file://wpa_supplicant.service"

FILES:${PN} += "${sysconfdir}/systemd/system/"

do_configure:append() {
	echo 'CONFIG_SAE=y' >>  wpa_supplicant/.config
	echo 'CONFIG_DPP=y' >>  wpa_supplicant/.config
	echo 'CONFIG_OWE=y' >>  wpa_supplicant/.config
	echo 'CONFIG_IEEE80211W=y' >>  wpa_supplicant/.config
}

do_install:append () {
	install -d ${D}${sysconfdir}/systemd/system
	install -m 0644 ${WORKDIR}/wpa_supplicant.service ${D}${sysconfdir}/systemd/system
}
