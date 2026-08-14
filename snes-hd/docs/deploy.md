# Deploy artifacts

`output/sneshd/` is the **build tree**. Do not copy it onto a Pi. The console only needs the two files under `output/sneshd/images/batocera/images/sneshd/`.

| File | Size | Role |
|---|---|---|
| `batocera-bcm2712-sneshd-44-20260814.img.gz` | 676M gz / **6.5G** raw | **Baseline disk image.** `dd` this onto a test bed, a family unit, or a blank production NVMe. Iterate the image; do not invent a second ship format. |
| `boot.tar.xz` | 662M | Same OS files (squash + kernel + initrd + firmware). In-place upgrade of an existing `BATOCERA` FAT without wiping SHARE. |

The 6.5G disk is not 6.5G of software. 1M gap + **6G FAT** (`BATOCERA`, ~662M used) + **512M BTRFS** (`SHARE` seed). No `SNES` partition on this image. Carts are USB disks labeled `SNES-*`.

There is no ISO. Pi 5 boots the FAT on NVMe.

## How we ship

This `.img.gz` is the baseline. We iterate it. Family consoles and new production NVMe disks get **`dd` of the current image**, then first-boot `S02resize` grows SHARE to the rest of the disk. Carts remain separate USB `SNES-*` disks.

Do **not** `dd` over the owner’s **existing** Pimoroni disk that already holds live SHARE + `SNES` data from the last machine. That disk is updated later with `boot.tar.xz` (or a future `sneshd-install`) so userdata survives.

## This pass (test bed)

Spare official-HAT NVMe at `10.10.44.191`. Must be **≥ 7G**. Confirm the device name before writing.

```
gzip -dc batocera-bcm2712-sneshd-44-20260814.img.gz \
  | sudo dd of=/dev/nvmeXn1 bs=4M status=progress conv=fsync
```

After `dd`, `blkid` should show `BATOCERA` (vfat) and `SHARE` (btrfs). No `SNES` label.

First boot: stock initramfs mounts squash from FAT; `S11share` mounts `SHARE`; `S12` seeds userdata from datainit.

## Existing data disk (later)

The live last-machine Pimoroni (SHARE + `SNES` already populated): extract `boot.tar.xz` onto FAT only. Do not `mkfs` SHARE or `SNES`. Never hardcode `/dev/sda`.

A three-partition genimage (FAT + SHARE + `SNES`) can land in a later image revision if family units need that layout from `dd`. Until then the two-partition baseline (FAT + SHARE, carts on USB) is what we ship and iterate.

## What is not an artifact

- `output/sneshd/build/`, `host/`, `per-package/`, `.config` — compile tree.
- `SNES/` archive and `*.cpio` — gitignored reference, not install media.
