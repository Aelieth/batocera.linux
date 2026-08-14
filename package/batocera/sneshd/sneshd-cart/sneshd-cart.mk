################################################################################
#
# sneshd-cart
#
################################################################################

SNESHD_CART_SOURCE =

define SNESHD_CART_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(SNESHD_CART_PKGDIR)/sneshd-common.sh \
		$(TARGET_DIR)/usr/lib/sneshd/sneshd-common.sh
	$(INSTALL) -D -m 0755 $(SNESHD_CART_PKGDIR)/sneshd-cart \
		$(TARGET_DIR)/usr/bin/sneshd-cart
	$(INSTALL) -D -m 0755 $(SNESHD_CART_PKGDIR)/sneshd-save-game-options \
		$(TARGET_DIR)/usr/bin/sneshd-save-game-options
	$(INSTALL) -D -m 0755 $(SNESHD_CART_PKGDIR)/sneshd-save-gamelist.py \
		$(TARGET_DIR)/usr/lib/sneshd/sneshd-save-gamelist.py
	$(INSTALL) -D -m 0755 $(SNESHD_CART_PKGDIR)/sneshd-cart-yank \
		$(TARGET_DIR)/usr/lib/sneshd/sneshd-cart-yank
	$(INSTALL) -D -m 0755 $(SNESHD_CART_PKGDIR)/sneshd-cart-scrub \
		$(TARGET_DIR)/usr/bin/sneshd-cart-scrub
	$(INSTALL) -D -m 0644 $(SNESHD_CART_PKGDIR)/99-sneshd-cart.rules \
		$(TARGET_DIR)/etc/udev/rules.d/99-sneshd-cart.rules
	$(INSTALL) -D -m 0755 $(SNESHD_CART_PKGDIR)/S13sneshd-cart-scrub \
		$(TARGET_DIR)/etc/init.d/S13sneshd-cart-scrub
endef

$(eval $(generic-package))
