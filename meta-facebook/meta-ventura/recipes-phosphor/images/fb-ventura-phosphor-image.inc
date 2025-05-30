# Ventura Image configuration

# Enable mdio-tools for communication with the PHY chip
OBMC_IMAGE_EXTRA_INSTALL:append = " \
    mdio-tools \
"

# Enable for run-time configurate the LT4232
OBMC_IMAGE_EXTRA_INSTALL:append = " \
    ftdi-eeprom \
"

# Enable mbpoll for communicate with smart valve by modbus command
OBMC_IMAGE_EXTRA_INSTALL:append = " \
    mbpoll \
"
# Monitor the GPIO on the system and take action.
OBMC_IMAGE_EXTRA_INSTALL:append = " \
    phosphor-gpio-monitor \
"

# Monitor gpio presence status
OBMC_IMAGE_EXTRA_INSTALL:append = " \
    phosphor-gpio-monitor-presence \
"

# Enable logger for sensor threshold event monitor
OBMC_IMAGE_EXTRA_INSTALL:append = " \
    phosphor-sel-logger \
"
