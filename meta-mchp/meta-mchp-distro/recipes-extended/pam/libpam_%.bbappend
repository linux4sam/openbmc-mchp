require ${BPN}-firstboot-empty-root.inc
require ${@bb.utils.contains('MCHP_FEATURES', 'mchpcore', '${BPN}-mchp.inc', '', d)}
