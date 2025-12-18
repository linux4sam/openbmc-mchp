inherit devicetree

COMPATIBLE_MACHINE:append:pic64gx-curiosity-kit = "|pic64gx-curiosity-kit"
COMPATIBLE_MACHINE:append:pic64gx-curiosity-kit-amp = "|pic64gx-curiosity-kit-amp"

DT_FILES_PATH:pic64gx = "${UNPACKDIR}/git/pic64gx_curiosity_kit"

LIC_FILES_CHKSUM = "file://git/COPYING;md5=775626b7bc958bdcc525161f725ece0f \
                    file://git/LICENSES/GPL-2.0;md5=e6a75371ba4d16749254a51215d13f97 \
                    file://git/LICENSES/MIT;md5=e8f57dd048e186199433be2c41bd3d6d"

do_compile[depends] = ""
DEPENDS:pic64gx = "dtc-native"

python do_compile() {

    bb.build.exec_func('devicetree_do_compile', d)
}

do_install:pic64gx() {
    cd ${B}
    for DTB_FILE in `ls *.dtbo`; do
        install -Dm 0644 ${B}/${DTB_FILE} ${D}/boot/${DTB_FILE}
    done
}

do_deploy:pic64gx() {
    cd ${B}
    for DTB_FILE in `ls *.dtbo`; do
        install -Dm 0644 ${B}/${DTB_FILE} ${DEPLOYDIR}/overlays/${DTB_FILE}
    done
}

FILES:${PN} += "/boot/*"
