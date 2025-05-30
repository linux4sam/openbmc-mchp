# Microchip SAMA5 defaults
require conf/machine/include/soc-family.inc
require conf/machine/include/arm/armv7a/tune-cortexa5.inc
require conf/machine/include/common-conf.inc

SOC_FAMILY = "sama5"

KBUILD_DEFCONFIG = "sama5_defconfig"

PREFERRED_PROVIDER_virtual/kernel:sama5 ?= "linux-mchp"
PREFERRED_PROVIDER_virtual/bootloader:sama5 ?= "u-boot-mchp"
PREFERRED_PROVIDER_u-boot:sama5 ?= "u-boot-mchp"

PREFERRED_PROVIDER_jpeg ?= "jpeg"
PREFERRED_PROVIDER_jpeg-native ?= "jpeg-native"

SERIAL_CONSOLES ?= "115200;ttyS0"
