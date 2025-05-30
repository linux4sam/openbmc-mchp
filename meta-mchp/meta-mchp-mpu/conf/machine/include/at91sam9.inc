# Microchip AT91SAM9 defaults
require conf/machine/include/soc-family.inc
require conf/machine/include/arm/armv5/tune-arm926ejs.inc
require conf/machine/include/common-conf.inc

SOC_FAMILY = "at91sam9"

KBUILD_DEFCONFIG = "at91_dt_defconfig"

PREFERRED_PROVIDER_virtual/kernel:at91sam9 ?= "linux-mchp"
PREFERRED_PROVIDER_virtual/bootloader:at91sam9 ?= "u-boot-mchp"
PREFERRED_PROVIDER_u-boot:at91sam9 ?= "u-boot-mchp"

SERIAL_CONSOLES ?= "115200;ttyS0"
