# SNES-HD

Dedicated Super Nintendo console image, built from this Batocera fork.

The working February 2025 machine (Batocera 41, live overlays) is archived under `SNES/` at the repo root. That directory is gitignored. Behavior is ported into `configs/batocera-sneshd.board`, `board/batocera/broadcom/sneshd/`, and `package/batocera/sneshd/`.

| Doc | What |
|---|---|
| [PLAN.md](../PLAN.md) | Point-by-point plan and session handoff |
| [disks.md](disks.md) | NVMe + cart labels, mounts, RAID1 |
| [hardware.md](hardware.md) | Pi 5, Pimoroni NVMe, GPIO, DAC, pads |
| [sinden.md](sinden.md) | Sinden / FPS cart — keep guns, cart-carried settings |
| [satellaview.md](satellaview.md) | Protected per-game BS-X saves (later phase) |
| [plymouth.md](plymouth.md) | Thin uClibc initramfs + `snes-load` (replicate `SNES/rootfs.cpio`) |
| [assets/](../assets/) | Logos, loading stills, `snes-load` theme |
| [cart-manager.md](cart-manager.md) | Label-based cart session, yank, format |

Build the Phase 1 board (stock BCM2712 packages, SNES-HD boot files):

```
make sneshd-build
```
