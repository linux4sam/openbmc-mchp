SUMMARY = "Microchip Linux libcamera framework"
SECTION = "libs"

LICENSE = "GPL-2.0-or-later & LGPL-2.1-or-later"

LIC_FILES_CHKSUM = "\
    file://LICENSES/GPL-2.0-or-later.txt;md5=fed54355545ffd980b814dab4a3b312c \
    file://LICENSES/LGPL-2.1-or-later.txt;md5=2a4f4fd2128ea2f65047ee63fbca9f68 \
"

SRC_URI = " \
        git://github.com/linux4microchip/libcamera-mchp.git;protocol=https;branch=master \
        file://0001-media_device-Add-bool-return-type-to-unlock.patch \
        file://0002-options-Replace-use-of-VLAs-in-C.patch \
        file://0001-rpi-Use-malloc-instead-of-variable-length-arrays.patch \
"

SRCREV = "b38b171c0ad27c7a9d956e08022281b0cb965a9f"

PE = "1"

S = "${WORKDIR}/git"

DEPENDS = "python3-pyyaml-native python3-jinja2-native python3-ply-native python3-jinja2-native udev gnutls chrpath-native libevent libyaml jpeg libpng"
DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES', 'qt', 'qtbase qtbase-native', '', d)}"

PACKAGES =+ "${PN}-gst ${PN}-pycamera ${PN}-ipa ${PN}-pipelines"

PACKAGECONFIG ??= "mchpcam"
PACKAGECONFIG[gst] = "-Dgstreamer=enabled,-Dgstreamer=disabled,gstreamer1.0 gstreamer1.0-plugins-base"
PACKAGECONFIG[pycamera] = "-Dpycamera=enabled,-Dpycamera=disabled,python3 python3-pybind11"
PACKAGECONFIG[mchpcam] = "-Dmchpcam=enabled,-Dmchpcam=disabled"

LIBCAMERA_PIPELINES ??= "auto"

EXTRA_OEMESON = " \
    -Dpipelines=${LIBCAMERA_PIPELINES} \
    -Dv4l2=true \
    -Dcam=enabled \
    -Dmchpcam=${@bb.utils.contains('PACKAGECONFIG', 'mchpcam', 'enabled', 'disabled', d)} \
    -Dlc-compliance=disabled \
    -Dtest=false \
    -Ddocumentation=disabled \
"

RDEPENDS:${PN} = "${@bb.utils.contains('DISTRO_FEATURES', 'wayland qt', 'qtwayland', '', d)}"

inherit meson pkgconfig python3native

do_configure:prepend() {
    sed -i -e 's|py_compile=True,||' ${S}/utils/ipc/mojo/public/tools/mojom/mojom/generate/template_expander.py
}

do_install:append() {
    chrpath -d ${D}${libdir}/libcamera.so
    chrpath -d ${D}${libexecdir}/libcamera/v4l2-compat.so
    if ${@bb.utils.contains('PACKAGECONFIG', 'mchpcam', 'true', 'false', d)}; then
        install -d ${D}${bindir}
        if [ -f ${B}/src/apps/mchpcam/mchpcam-still ]; then
            install -m 0755 ${B}/src/apps/mchpcam/mchpcam-still ${D}${bindir}
        fi
    fi
}

do_package:append() {
    bb.build.exec_func("do_package_recalculate_ipa_signatures", d)
}

do_package_recalculate_ipa_signatures() {
    local modules
    for module in $(find ${PKGD}/usr/lib/libcamera -name "*.so.sign"); do
        module="${module%.sign}"
        if [ -f "${module}" ] ; then
            modules="${modules} ${module}"
        fi
    done

    ${S}/src/ipa/ipa-sign-install.sh ${B}/src/ipa-priv-key.pem "${modules}"
}

FILES:${PN} += " ${libexecdir}/libcamera/v4l2-compat.so ${libdir}/libcamera/*.so* ${datadir}/libcamera ${bindir}/mchpcam-*"
FILES:${PN}-gst = "${libdir}/gstreamer-1.0"
FILES:${PN}-ipa = "${libdir}/libcamera/ipa_*.so* ${libdir}/libcamera/*.so.sign ${datadir}/libcamera/ipa/*"
FILES:${PN}-pipelines = "${datadir}/libcamera/pipeline/*"
FILES:${PN}-pycamera = "${PYTHON_SITEPACKAGES_DIR}/libcamera"

# libcamera-v4l2 explicitly sets _FILE_OFFSET_BITS=32 to get access to
# both 32 and 64 bit file APIs.
GLIBC_64BIT_TIME_FLAGS = ""
