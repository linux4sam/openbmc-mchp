SUMMARY = "Virtual Sensors"
DESCRIPTION = "virtual sensors created from existing sensors and config data"
HOMEPAGE = "https://github.com/openbmc/phosphor-virtual-sensor"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9e69ba356fa59848ffd865152a3ccc13"
DEPENDS:append = "\
    exprtk \
    nlohmann-json \
    phosphor-dbus-interfaces \
    phosphor-logging \
    sdbusplus \
"
SRCREV = "06f8874f26adff78f960c8937ce11b723ad31e87"
PV = "0.1+git${SRCPV}"
PR = "r1"

SRC_URI = "git://github.com/openbmc/phosphor-virtual-sensor.git;protocol=https;branch=master"

S = "${WORKDIR}/git"
SYSTEMD_SERVICE:${PN} = "phosphor-virtual-sensor.service"

inherit meson pkgconfig
inherit systemd
