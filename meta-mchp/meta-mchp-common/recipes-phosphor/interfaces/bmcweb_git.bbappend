EXTRA_OEMESON:append = " -Dhttp-body-limit=100 \
                         -Dredfish-dbus-log=enabled \
                       "

# Use revision that fixes bmcweb crash when adding fan sensor with connector
SRCREV = "e7bcf475904424ac375d408f4feb0a717787c2a4"