# Hardware

Two machines. Do not mix them up.

## Test bed (current flash)

Plain Pi 5 + official Pi 5 NVMe HAT. All Pi equipment. **Clean software baseline.** No InnoMaker DAC, no SNES GPIO, no Leonardo, no Pimoroni.

- Address (this pass): `10.10.44.191`
- HDMI only. `allo-boss-dac` in `config.txt` will probe and fail (`pcm512x -11`). **Ignore that here.**
- Phase 4 (GPIO / HiFi / MSU-1 / 8bitdo) stays parked until the SNES shell is on the bench.

## Production console (later)

Pi 5 inside a SNES shell, not a generic SBC image.

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
