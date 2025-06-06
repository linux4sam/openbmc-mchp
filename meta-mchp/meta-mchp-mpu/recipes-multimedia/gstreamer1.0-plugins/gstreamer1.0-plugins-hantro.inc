SUMMARY = "Hantro plugins for GStreamer"
SECTION = "multimedia"
LICENSE = "LGPL-2.1-only"
HOMEPAGE = "http://www.gstreamer.net/"
DEPENDS = "gstreamer1.0 gstreamer1.0-plugins-base g1-decoder"

inherit autotools-brokensep pkgconfig gettext

LIC_FILES_CHKSUM = "file://COPYING.LESSER;md5=4fbd65380cdd255951079008b364516c"

COMPATIBLE_MACHINE = "sama5d4"
DEPENDS += "gtk-doc-native libdrm"

SRC_URI = "git://github.com/linux4sam/gst1-hantro-g1;protocol=https;branch=master \
           git://github.com/GStreamer/common.git;protocol=https;branch=master;destsuffix=git/common;name=common \
           "

SRCREV_common = "9aed1d7a80a38b76f9441ecf181942df99f09c38"
SRCREV_FORMAT = "base"

S = "${WORKDIR}/git"

FILES:${PN} += "${libdir}/gstreamer-1.0/*.so"
FILES:${PN}-dbg += "${libdir}/gstreamer-1.0/.debug"
FILES:${PN}-dev += "${libdir}/gstreamer-1.0/*.la"
FILES:${PN}-staticdev += "${libdir}/gstreamer-1.0/*.a"
