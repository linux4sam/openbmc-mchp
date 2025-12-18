SUMMARY = "Minimal static inventory for OpenBMC updater compatibility"
DESCRIPTION = "Provides a minimal /system inventory object to ensure valid D-Bus associations"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit allarch
inherit phosphor-inventory-manager

SRC_URI = "file://basic-inventory.yaml"

do_install() {
    install -D ${UNPACKDIR}/basic-inventory.yaml ${D}${base_datadir}/events.d/basic-inventory.yaml
}

FILES:${PN} += "${base_datadir}/events.d/basic-inventory.yaml"
