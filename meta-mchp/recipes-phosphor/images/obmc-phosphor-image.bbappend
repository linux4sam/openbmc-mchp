# Ensure kernel modules are included in the image
IMAGE_INSTALL:append = " kernel-modules"

# Ensure u-boot-mchp package is included in the image
IMAGE_INSTALL:append = " u-boot-mchp"

# Remove deprecated webui
IMAGE_INSTALL:remove = "phosphor-webui"

# Add additional packages to the image
OBMC_IMAGE_EXTRA_INSTALL:append = " entity-manager"
OBMC_IMAGE_EXTRA_INSTALL:append = " fru-device"
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-health-monitor"
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-ipmi-host"
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-ipmi-net"
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-state-manager"
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-logging"
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-sel-logger"
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-gpio-monitor"
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-gpio-monitor-presence"
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-led-manager"
OBMC_IMAGE_EXTRA_INSTALL:append = " obmc-console"
OBMC_IMAGE_EXTRA_INSTALL:append = " webui-vue"
OBMC_IMAGE_EXTRA_INSTALL:append = " ipmitool"

