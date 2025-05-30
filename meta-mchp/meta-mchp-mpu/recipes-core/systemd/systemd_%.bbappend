FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = " \
    backlight \
    binfmt \
    gshadow \
    firstboot \
    hibernate \
    ima \
    localed \
    logind \
    machined \
    nss-mymachines \
    nss-resolve \
    polkit \
    pam \
    quotacheck \
    randomseed \
    seccomp \
    smack \
    sysvinit \
    utmp \
    vconsole \
"
