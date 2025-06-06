DESCRIPTION = "Microchip EGT sample applications from the community"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9d979c7e3d1771e43c4e0ac149beb4d0"

PACKAGES = "\
    ${PN} \
    ${PN}-dev \
    ${PN}-dbg \
"
DEPENDS = " libegt"

SRC_URI = "git://github.com/linux4sam/egt-samples-contribution.git;protocol=https;branch=master "

PV = "1.3+git${SRCPV}"
SRCREV = "0e9b868f38ca91faa31809088ad05f2617d47133"

S = "${WORKDIR}/git"

FILES:${PN} += " \
    ${datadir}/egt/samples/* \
"

EXTRA_OECMAKE += "-DEGT_SAMPLES_CONTRIBUTION_SLIDERB=true"

inherit pkgconfig cmake

python __anonymous () {
    endianness = d.getVar('SITEINFO_ENDIANNESS')
    if endianness == 'be':
        raise bb.parse.SkipRecipe('Requires little-endian target.')
}
