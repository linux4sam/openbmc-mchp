FILESEXTRAPATHS:prepend := "${THISDIR}/:"

SRC_URI:append = " \
	file://hostapd@.service \
	file://wilc_hostapd_open.conf \
	file://wilc_hostapd_wpa.conf \
"

FILES:${PN} += " \
	${sysconfdir}/systemd/system/ \
	${sysconfdir}/network/ \
"

S = "${WORKDIR}/hostapd-${PV}"

do_configure:append() {
	echo 'CONFIG_SAE=y' >>  ${S}/hostapd/.config
	echo 'CONFIG_DPP=y' >>  ${S}/hostapd/.config
	echo 'CONFIG_OWE=y' >>  ${S}/hostapd/.config
	echo 'CONFIG_IEEE80211W=y' >>  ${S}/hostapd/.config
}

do_install:append () {
	install -d ${D}${sysconfdir}/systemd/system
	install -d ${D}${sysconfdir}/network
	install -m 0644 ${WORKDIR}/hostapd@.service ${D}${sysconfdir}/systemd/system
	install -m 0644 ${WORKDIR}/wilc_hostapd_open.conf ${D}${sysconfdir}/network
	install -m 0644 ${WORKDIR}/wilc_hostapd_wpa.conf ${D}${sysconfdir}/network
}
