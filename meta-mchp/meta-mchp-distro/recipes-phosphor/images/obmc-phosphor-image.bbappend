# Ensure kernel modules are included in the image
OBMC_IMAGE_EXTRA_INSTALL:append = " kernel-modules"

# Ensure u-boot-mchp package is included in the image
OBMC_IMAGE_EXTRA_INSTALL:append = " u-boot-mchp"

# Force inclusion of e2fsprogs-tune2fs in the image
OBMC_IMAGE_EXTRA_INSTALL:append = " e2fsprogs-tune2fs"

# Force inclusion of inventory manager
OBMC_IMAGE_EXTRA_INSTALL:append = " phosphor-inventory-manager"

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
OBMC_IMAGE_EXTRA_INSTALL:append = " dbus-sensors"
OBMC_IMAGE_EXTRA_INSTALL:append = " dummy-power"

# Remove deprecated webui
IMAGE_INSTALL:remove = "phosphor-webui"

# Remove skeleton-control-power as we are adding dummy-power
IMAGE_INSTALL:remove = "phosphor-skeleton-control-power"

# Remove skeleton-control-power as we are adding dummy-power
IMAGE_INSTALL:remove = "phosphor-skeleton-control-power"

# Remove obmc ikvm
IMAGE_FEATURES:remove = "obmc-ikvm"

# Allow root to start with an empty, expired password so first boot can set it.
# Without this feature, poky's rootfs postcommands lock empty root passwords.
IMAGE_FEATURES:append = " empty-root-password"

# Replace the upstream default root password ('0penBmc') with an empty one.
# The passwd-expire line below keeps the first-boot password change enforced.
EXTRA_USERS_PARAMS:pn-obmc-phosphor-image = " usermod -p '' root;"

# Add root to priv-admin group
EXTRA_USERS_PARAMS:append = " usermod -a -G priv-admin root;"

# Force root password to expire on first login. The same setting is kept in
# Microchip local.conf templates for Yocto-layer commonality; keep it here too
# so OpenBMC release images enforce this regardless of the build template used.
EXTRA_USERS_PARAMS:append = " passwd-expire root;"
