# Disks, labels, and mounts

Identity is **BTRFS filesystem labels**, never `/dev/sda`.

## NVMe (the console)

Pimoroni NVMe Base, `nvme0n1`.

| Partition | FS | Label | Role |
|---|---|---|---|
| p1 | FAT32 | `BATOCERA` | Firmware, kernel, initrd. Do not treat as userdata. |
| p2 | BTRFS | `SHARE` | Admin userdata. `/media/SHARE`. `/userdata` when no cart. |
| p3 | BTRFS | `SNES` | Console extras, cart theme cache, later backups. `/media/SNES`. |

First image (`…-20260814.img.gz`) still has **ext4 SHARE** (lean `S11` will fail that mount and fall back to tmpfs). Next images: FAT boot + **BTRFS SHARE** (512M seed, `autoresize` grows it). OS root stays squash until Phase 5. Partition 3 (`SNES`) is not in genimage yet.

## USB3 SSD (the cartridge)

A disk is a cart if it has a BTRFS filesystem labeled `SNES-<id>` (example: `SNES-ADVN`) that contains a `batocera/` userdata tree.

| Partition | FS | Label | Role |
|---|---|---|---|
| p1 | BTRFS | `SNES-<id>` | Cart library, **read-only**. `/media/SNES-<id>`, bind `…/batocera` → `/userdata`. |
| p2 | BTRFS | (optional) | RAID1 pair of p1, same FS UUID. |
| p3 | BTRFS | `SAVES` | Writable saves + `batocera-custom.conf` + `gamelist-custom.xml`. `/media/SAVES` and `/userdata/saves`. |

No `SNES-*` found → admin mode: SHARE is `/userdata`.

## Overlay rules (port of `SNES/postshare.sh`)

| Source | Target | Mode |
|---|---|---|
| `/media/SHARE` | `/userdata` | admin only, rw |
| `/media/SNES-<id>/batocera` | `/userdata` | cart, ro bind |
| `/tmp/SNES/system` (copy of SHARE `system`) | `/userdata/system` | rw tmpfs bind |
| `/media/SAVES` | `/userdata/saves` | rw |
| `/media/SNES/carts/<id>/themes` | `/userdata/themes` | ro |
| custom gamelist on SAVES | `/userdata/roms/snes/gamelist.xml` | bind when present |

Allowlisted cart/SAVES config: `snes[` keys and `controllers.*` (includes Sinden). Host keeps wifi, timezone, hostname, audio device, governor.

## RAID1 carts

Two equal partitions, `btrfs device add` + `balance -dconvert=raid1`. Remount `degraded` if a side is sick. After boot, idle `btrfs scrub` when `cart_raid=1`.
