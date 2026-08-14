################################################################################
#
# sneshd-admin
#
################################################################################

SNESHD_ADMIN_SOURCE =
SNESHD_ADMIN_DEPENDENCIES = sneshd-cart

define SNESHD_ADMIN_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(SNESHD_ADMIN_PKGDIR)/sneshd-reset-game-options \
		$(TARGET_DIR)/usr/bin/sneshd-reset-game-options
	$(INSTALL) -D -m 0755 $(SNESHD_ADMIN_PKGDIR)/sneshd-reset-system-defaults \
		$(TARGET_DIR)/usr/bin/sneshd-reset-system-defaults
	$(INSTALL) -D -m 0755 $(SNESHD_ADMIN_PKGDIR)/sneshd-format-cart \
		$(TARGET_DIR)/usr/bin/sneshd-format-cart
endef

$(eval $(generic-package))
