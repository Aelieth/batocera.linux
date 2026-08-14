# `SNES/CustomSNES/initialize/` — keystone parse

Not a spec. Overlay-era rsync onto a running Batocera 41. `initialize.sh` remounts, copies the tree to `/`, `batocera-save-overlay`. We do **not** rsync this. We lift **settings and intent** into datainit / board overlay / packages.

`initialize.sh` also *moves* network init scripts onto `/media/SNES` and starts them later via the `network_services` service. That is overlay diet, not something to copy onto the test bed (we need SSH).

Binary `usr/lib/libretro/bsnes_hd_libretro.so` is ignored (old ABI). Init.d copies, `postshare.sh`, GPIO/HiFi/powerswitch, MSU-1 hooks, Leonardo `es_input`, `blacklist brcmfmac/bluetooth` — later or never on this Pi HAT.

## Apply as software defaults (when we start)

From `userdata/system/batocera.conf` + `boot/batocera-boot.conf` + `es_settings.cfg`:

| Setting | Archive value | Why |
|---|---|---|
| `system.hostname` | `SNES` | Already intended; datainit still `BATOCERA` |
| `system.timezone` | `America/Chicago` | Board already |
| `system.language` | `en_US` | Fine default |
| `wifi.enabled` | `0` | Matches `disable-wifi` overlay |
| `system.samba.enabled` | `0` | Samba not in the image |
| `kodi.enabled` / atstartup / xbutton | `0` | No Kodi |
| `splash.screen.enabled` | `0` | Already in boot.conf |
| `updates.enabled` | `0` | Locked console; no random upgrades |
| `global.shaderset` | `none` | Clean pixels |
| `global.bezel` | `none` | Family games under SNES; bezels later if a cart wants them |
| `system.cec.standby` | `0` | Do not CEC-off the TV |
| `es.resolution` | `max-1920x1080` | Test-bed HDMI |
| `system.cpu.governor` | `schedutil` | After boot turbo; S18 may already apply |
| `audio.volume` / `audio.bgmusic` | `80` / `1` | ES music on; device stays `auto` on this HAT |
| `CollectionSystemsAuto` | `""` | No Favorites / All Games |
| `StartupSystem` | `snes` | Land on the SNES group |
| `HiddenSystemsShowGames` | `false` | |
| `ThemeSet` / `ThemeColorSet` / `ThemeRegionName` | carbon / red / us | Their ES look |
| `ClockMode12`, `InvertButtons` | true | ES feel from the old box |
| `SlideshowScreenSaver*` | custom dir + 20s | Need the screensaver image if we want that look |
| RetroArch pad hotkeys | all `nul` | Gamepad cannot open RA menu / savestate / exit (keyboard still can in custom.cfg) |

`es_systems.cfg` in the archive is already family-only with `<group>snes</group>` (plus leftover nes/fds). Confirms the grouping we locked.

## Lift later (not this test bed)

| Piece | Why later |
|---|---|
| `system.services=… powerswitch HiFi_audio` | SNES shell |
| `audio.device=` InnoMaker | Parked |
| `es_input.cfg` Leonardo / 8BitDo | Parked |
| MSU-1 `game-start` / `game-end` scripts | Phase 4 |
| `network_services` delaying connman/dropbear | We need SSH on the bed |
| `99-cart-removal.rules` | Already ported as `99-sneshd-cart.rules` |
| `cart_maintenance` scrub | Already `S13sneshd-cart-scrub` |
| `CPU_performance` | Same job as Batocera `S18governor` — do not dual-run |
| `retroarchcustom.cfg` viewport `273,24,1374x1032` | Tuned to that TV/bezel; do not copy |
| `video_driver=gl`, `audio_driver=alsathread` | v41; Pi 5 now is glcore/vulkan + PipeWire |
| `savefile_directory=/userdata/saves/snes` for everything | Breaks satellaview/sufami/sgb save split |
| `blacklist bluetooth` | Conflicts with test-bed SSH/debug; production already `dtoverlay=disable-bt` |
| `bsnes_hd_libretro.so` blob | Rebuild, do not copy |
| Core-option deltas vs our tree (blur OFF, entropy High, mosaic 2x, bgGrad 8) | Our tree used the other “working Pi 5” dump. Do not overwrite without a side-by-side play test |

## Do not take as gospel

- Whole-tree rsync to `/` + `batocera-save-overlay`
- Hardcoded `/dev/nvme0n1p3` in `initialize.sh`
- Moving stock `S08connman` / `S50dropbear` off the rootfs
- `system.es.menu=none` is **commented** in the archive — not enabled. Do not hide the ES menu unless you ask.
- `controllers.bluetooth.enabled=1` in conf while `config.txt` disabled BT. Leave our overlay as-is on this HAT.
