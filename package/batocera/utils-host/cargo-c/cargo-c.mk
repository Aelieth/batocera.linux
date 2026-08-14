################################################################################
#
# cargo-c
#
################################################################################

CARGO_C_VERSION = v0.10.19
CARGO_C_SITE = $(call github,lu-zero,cargo-c,$(CARGO_C_VERSION))
CARGO_C_LICENSE = MIT License
CARGO_C_LICENSE_FILES = LICENSE

HOST_CARGO_C_DEPENDENCIES = host-pkgconf host-rustc host-openssl
# Vendored kstring 2.0.4 declares rust-version 1.96; Buildroot rust-bin is 1.95.
# The crate still builds; do not bump the whole rust toolchain for an MSRV stamp.
# cargo install re-checks MSRV independently of cargo build.
HOST_CARGO_C_CARGO_BUILD_OPTS = --ignore-rust-version
HOST_CARGO_C_CARGO_INSTALL_OPTS = --ignore-rust-version

$(eval $(host-cargo-package))
