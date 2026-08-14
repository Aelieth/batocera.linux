# SNES-HD board (`broadcom/sneshd`)

Raspberry Pi 5 image for the SNES-HD console (Pimoroni NVMe Base, USB3 SSD carts, InnoMaker HiFi DAC).

This board reuses the stock Batocera **BCM2712** kernel. `BR2_PACKAGE_BATOCERA_SNESHD` turns off the all-systems umbrella and keeps RetroArch + bsnes / bsnes-hd / snes9x / mesen-s. Sinden stays (via `BATOCERA_GUNS`). Cart manager, BTRFS root, and Plymouth come later.

Build:

```
make sneshd-build
```

(or the equivalent `make sneshd` / `make sneshd-config` targets this tree already generates from `configs/batocera-sneshd.board`)
