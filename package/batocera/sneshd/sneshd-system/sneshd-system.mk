################################################################################
#
# sneshd-system
#
################################################################################

SNESHD_SYSTEM_SOURCE =
SNESHD_SYSTEM_KCONFIG_VAR = BR2_PACKAGE_BATOCERA_SNESHD
SNESHD_SYSTEM_DEPENDENCIES = retroarch libretro-bsnes libretro-bsnes-hd \
	libretro-snes9x libretro-mesens batocera-userdatainit batocera-es-system

define SNESHD_SYSTEM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(SNESHD_SYSTEM_PKGDIR)/retroarch-core-options.cfg \
		$(TARGET_DIR)/usr/share/batocera/datainit/system/configs/retroarch/cores/retroarch-core-options.cfg
	$(INSTALL) -D -m 0644 $(SNESHD_SYSTEM_PKGDIR)/es_settings.cfg \
		$(TARGET_DIR)/usr/share/batocera/datainit/system/configs/emulationstation/es_settings.cfg
endef

# Datainit prune (kodi / ports / gb / gbc) lives in
# board/batocera/scripts/post-build-script.sh. A package install hook
# loses to per-package rsync of userdatainit / es-system.

$(eval $(generic-package))
