# Ensure kernel modules are included in the image
IMAGE_INSTALL:append = " kernel-modules"

# Ensure u-boot-mchp package is included in the image
IMAGE_INSTALL:append = " u-boot-mchp"
