# Sinden / FPS cart

A dedicated cartridge holds Super Scope / Justifier / Sinden settings. The **host image keeps the gun stack**; the cart carries calibration and per-game mappings.

## Do not cut

`BR2_PACKAGE_BATOCERA_GUNS` is **gated off** on SNES-HD. `sneshd-system` selects only:

- `sinden-guns` (Mono `LightgunMono.exe`, udev, `uvcvideo.conf` — also pulls Mono, libv4l, libgdiplus)
- `sinden-guns-libs` (arch-specific `libCameraInterface.so`)
- `lightguns-games-precalibrations`

Aimtrak / Gun4IR / OpenFIRE / etc. stay in the tree but are not built. If Sinden fails to enumerate, add the missing package via `select` in `sneshd-system` — do not re-enable the whole umbrella.

Also keep Mono, libv4l, evsieve, and the `uvcvideo` module. **Wheels** stay cut. Guns stay.

`dtoverlay=disable-camera` is the Pi **CSI** camera. Sinden is USB UVC. Leave CSI disabled.

## How Batocera wires a Sinden

1. USB input + `/dev/video*` appear.
2. `99-sinden.rules` runs `virtual-sindenlightgun-add`.
3. That script **waits until `/userdata` is up** (`/var/run/virtual-events.waiting`) so it can read `batocera-settings-get`.
4. It builds a virtual `Sinden lightgun` with `ID_INPUT_GUN=1` and `ID_INPUT_GUN_NEED_BORDERS=1`.
5. `LightgunMono.exe.config` is instantiated under `/var/run/sinden/`.

Cart manager must finish its binds **before** that waiting queue is drained, or the gun starts with host defaults instead of cart settings.

## Settings the cart owns

These keys are already `controllers.*`, so the old postshare allowlist already merges them from `SAVES/batocera-custom.conf`:

| Key | Role |
|---|---|
| `controllers.guns.borderssize` | Border thickness (`medium`, …) |
| `controllers.guns.bordersmode` | `auto` or forced |
| `controllers.guns.bordersratio` | Aspect for the white border |
| `controllers.guns.borderscolor` | `white` / `red` / `green` / `blue` |
| `controllers.guns.sinden.contrast` | Camera (default 60) |
| `controllers.guns.sinden.brightness` | Camera (default 120) |
| `controllers.guns.sinden.exposure` | Camera (default -7) |
| `controllers.guns.recoil` | `gun`, `gun-quiet`, `machinegun`, `machinegun-quiet` |

Per-game gun mappings and bezels live in the cart `batocera/` tree. Recoil and camera exposure are per-cart, not host defaults.

## Hardware checks still owed

- Sinden enumerates with Wi‑Fi/BT overlays disabled
- Borders work under labwc + bsnes/snes9x Super Scope titles on Pi 5
- Yank-protection rules stay limited to `SNES-*` / `SAVES` so a Sinden USB video blip does not power the console off
