# U-Boot Environments for Microchip boards

ENV_FILENAME = "uboot.env"
ENV_FILEPATH = "${WORKDIR}/envs"

do_compile:append() {
    if [ -e "${ENV_FILEPATH}/${MACHINE}.txt" ]; then
        bbnote "Compile U-Boot environment for ${MACHINE}"
        ${B}/tools/mkenvimage ${MKENVIMAGE_EXTRA_ARGS} -s ${UBOOT_ENV_SIZE} ${ENV_FILEPATH}/${MACHINE}.txt -o ${ENV_FILENAME}
    else
        bbnote "No custom environment available for ${MACHINE}."
    fi
}

do_deploy:append() {
    if [ -e  ${B}/${ENV_FILENAME} ]; then
        install -Dm 0644 ${B}/${ENV_FILENAME} ${DEPLOYDIR}
    fi
}
