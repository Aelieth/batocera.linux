# Hardware

This is a Pi 5 inside a SNES shell, not a generic SBC image.

| Piece | Detail |
|---|---|
| SoC | Raspberry Pi 5 (BCM2712) |
| System disk | Pimoroni NVMe Base (`dtparam=pciex1`). Gen3 (`pciex1_gen=3`) is opt-in. |
| Carts | USB3 SSD, UASP |
| DAC | InnoMaker HiFi, `dtoverlay=allo-boss-dac-pcm512x-audio` |
| Power / reset | GPIO BCM 8 shutdown, BCM 15 reset (`lgpio`) |
| Pads | Arduino Leonardo on the front ports, USB hub into the Pi; authentic SNES pads + power LED |
| Lightguns | Sinden (USB UVC). CSI camera overlay stays **disabled**. |
| Wireless | Wi‑Fi and Bluetooth overlays disabled in `config.txt` |
| Thermals | `arm_freq=2200`, `gpu_freq=500` — required for sustained bsnes-hd 3x Mode 7 |

Cart yank: udev on `SNES-*` / `SAVES` remove → kill ES → `poweroff -f`. Do not match other USB devices (Sinden video reconnects must not trip this).
