# Thin uClibc initramfs + snes-load

The recovered ramdisk **is** the spec. Replicate it. Do not grow it.

| File | Size | libc | Use |
|---|---|---|---|
| `SNES/rootfs.cpio` (+ `.lz4` ~12M) | 26M | **uClibc-ng 1.0.51** | Working splash. Theme `snes-load`. Model for the shipped initramfs. |
| `rootfs.cpio` (repo root) | 172M | glibc | Later experiment. Stock themes. Plymouth commented out. **Anti-pattern.** |

There is no top-level `/share`. Theme lives at `usr/share/plymouth/themes/snes-load/` in the cpio. Project copy: [`../assets/plymouth/snes-load/`](../assets/plymouth/snes-load/). The image still installs from `package/batocera/sneshd/sneshd-plymouth/` until the package is retargeted.

## Why uClibc

Every KB in the ramdisk is milliseconds after HDMI comes up. Pi EEPROM + TV handshake is often **~8s** of the 10s budget; the first converge is frequently missed on a TV and that is OK. The ramdisk must be ready the moment the display appears.

The **OS stays glibc** (Sinden/Mono). Only the initramfs is uClibc-ng.

## Allowlist

Add nothing without a boot-path reason:

- `plymouthd` + `script.so` + drm/fb renderers
- `snes-load` only (no glow/spinner/solar)
- busybox
- `btrfs` / `btrfs-progs` to mount `@` and SHARE
- `pcie-brcmstb`, `nvme`, `xhci-*`

## Theme contract

`etc/plymouth/plymouthd.conf`:

```
[Daemon]
Theme=snes-load
ShowDelay=0
DeviceTimeout=8
```

`plymouth update --status=`:

| Status | Phase |
|---|---|
| `busy=1` / `busy=0` | reverse spin vs clockwise |
| `switch_root=1` | clockwise, pause at yellow home |
| `animate_expand=1` | dots → SNES silhouette |
| `display_logo=1` | logo fade-in |

Archive `init` starts plymouthd **before** NVMe/USB modprobe. Production must `switch_root` after `display_logo` instead of `exec /bin/sh`.
