################################################################################
#
# sneshd-plymouth
#
# Theme + plymouthd.conf from SNES/rootfs.cpio. plymouthd itself is not
# installed here — it belongs in the uClibc-ng initramfs.
#
################################################################################

SNESHD_PLYMOUTH_SOURCE =

define SNESHD_PLYMOUTH_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(SNESHD_PLYMOUTH_PKGDIR)/etc/plymouth/plymouthd.conf \
		$(TARGET_DIR)/etc/plymouth/plymouthd.conf
	mkdir -p $(TARGET_DIR)/usr/share/plymouth/themes
	cp -a $(SNESHD_PLYMOUTH_PKGDIR)/themes/snes-load \
		$(TARGET_DIR)/usr/share/plymouth/themes/
endef

$(eval $(generic-package))
