# sneshd-plymouth

Lifted from `SNES/rootfs.cpio` (uClibc-ng 1.0.51 initramfs). That cpio is the
size class we replicate: Plymouth + this theme + BTRFS + NVMe/USB modules.

| Path here | Role |
|---|---|
| `etc/plymouth/plymouthd.conf` | `Theme=snes-load`, `ShowDelay=0` |
| `themes/snes-load/` | script theme: four SNES-color dots → expand → logo |
| `reference/init.snes-archive` | archive test `init` (ends in `/bin/sh`; not production) |

`plymouth update --status=` values the script understands: `busy=1`/`0`,
`switch_root=1`, `animate_expand=1`, `display_logo=1`.

This package installs **theme data only**. Do not select a glibc `plymouthd`
on the OS. The daemon is built into the thin uClibc ramdisk.
