do_install:append() {
   sed -i 's/pam_unix.so quiet/pam_unix.so nullresetok quiet/' \
      ${D}${sysconfdir}/pam.d/common-auth
   sed -i 's/pam_unix.so sha512 use_authtok/pam_unix.so sha512 nullresetok use_authtok/' \
      ${D}${sysconfdir}/pam.d/common-password
}
