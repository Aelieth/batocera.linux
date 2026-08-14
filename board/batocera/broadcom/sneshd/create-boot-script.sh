#!/bin/bash

# HOST_DIR = host dir
# BOARD_DIR = board specific dir
# BUILD_DIR = base dir/build
# BINARIES_DIR = images dir
# TARGET_DIR = target dir
# BATOCERA_BINARIES_DIR = batocera binaries sub directory

HOST_DIR=$1
BOARD_DIR=$2
BUILD_DIR=$3
BINARIES_DIR=$4
TARGET_DIR=$5
BATOCERA_BINARIES_DIR=$6

mkdir -p "${BATOCERA_BINARIES_DIR}/boot/boot" || exit 1

cp -pr "${BINARIES_DIR}/rpi-firmware/"*     "${BATOCERA_BINARIES_DIR}/boot/" || exit 1
cp -f  "${BINARIES_DIR}/"*.dtb              "${BATOCERA_BINARIES_DIR}/boot/" || exit 1
cp     "${BOARD_DIR}/boot/config.txt"       "${BATOCERA_BINARIES_DIR}/boot/" || exit 1
cp     "${BOARD_DIR}/boot/cmdline.txt"      "${BATOCERA_BINARIES_DIR}/boot/" || exit 1

cp "${BINARIES_DIR}/Image"           "${BATOCERA_BINARIES_DIR}/boot/boot/linux"           || exit 1
cp "${BINARIES_DIR}/initrd.lz4"      "${BATOCERA_BINARIES_DIR}/boot/boot/"                || exit 1
cp "${BINARIES_DIR}/rootfs.squashfs" "${BATOCERA_BINARIES_DIR}/boot/boot/batocera.update" || exit 1
if [ -f "${BINARIES_DIR}/rufomaculata" ]; then
    cp "${BINARIES_DIR}/rufomaculata" "${BATOCERA_BINARIES_DIR}/boot/boot/rufomaculata.update" || exit 1
fi

# Console identity in the staged boot.conf (post-image copies this file to /boot)
if [ -f "${BINARIES_DIR}/batocera-boot.conf" ]; then
    sed -i \
        -e 's/^system.hostname=.*/system.hostname=SNES/' \
        -e 's/^#\?system.hostname=.*/system.hostname=SNES/' \
        "${BINARIES_DIR}/batocera-boot.conf"
    grep -q '^system.hostname=' "${BINARIES_DIR}/batocera-boot.conf" \
        || echo 'system.hostname=SNES' >> "${BINARIES_DIR}/batocera-boot.conf"
    if grep -q '^system.timezone=' "${BINARIES_DIR}/batocera-boot.conf"; then
        sed -i 's/^system.timezone=.*/system.timezone=America\/Chicago/' "${BINARIES_DIR}/batocera-boot.conf"
    else
        echo 'system.timezone=America/Chicago' >> "${BINARIES_DIR}/batocera-boot.conf"
    fi
    if grep -q '^splash.screen.enabled=' "${BINARIES_DIR}/batocera-boot.conf"; then
        sed -i 's/^splash.screen.enabled=.*/splash.screen.enabled=0/' "${BINARIES_DIR}/batocera-boot.conf"
    else
        echo 'splash.screen.enabled=0' >> "${BINARIES_DIR}/batocera-boot.conf"
    fi
fi

exit 0
