# Test-bed fix list (plain Pi 5 + Pi HAT)

Machine: `10.10.44.191`, board `sneshd`, hostname currently `SNES`.  
#1 and #1b applied on live SHARE 2026-08-14 (persist). Cart `blkid` scripts copied to overlay only — gone on reboot until the next image. DAC / GPIO / HiFi / MSU-1 stay parked.

Parked on purpose: `allo-boss-dac` probe `-11`, HDMI-only audio, no powerswitch, no Leonardo.

## Agreed UI defaults (locked)

ES groups by **`group: snes`** in `es_systems.yml`. Satellaview, Sufami, SGB, SGB-MSU1, and SNES-MSU1 are **not** separate carousel systems. Their games show under **SNES**. The rom still lives in its own folder (`roms/satellaview`, `roms/sgb-msu1`, …). Emulator/core is chosen from that system via `configgen-defaults-sneshd.yml` (bsnes-hd for snes / snes-msu1 / sgb-msu1; mesen-s for sgb; snes9x for satellaview / sufami).

Do **not** set `snes.ungroup=true` — that would split the family back out.

Automatic Game Collections stay **off** (no Favorites, no All Games). That is a different ES row, not the family group.

```xml
<string name="CollectionSystemsAuto" value="" />
<string name="StartupSystem" value="snes" />
<bool name="HiddenSystemsShowGames" value="false" />
```

Live `es_settings.cfg` does **not** set `CollectionSystemsAuto` (stock collections still on). It already has `HiddenSystems=gb,gbc,ports`. Those three are leftover mesen-s systems, not part of the SNES group.

## Open items

| # | Item | Where | Live now | Fix (when we start) |
|---|---|---|---|---|
| 1 | Auto collections / Favorites / All Games + ES look | `es_settings.cfg` | unset → ES default collections on | From keystone: `CollectionSystemsAuto=""`, `StartupSystem=snes`, carbon/red/us, `HiddenSystemsShowGames=false`. Datainit + live SHARE. See [initialize-keystone.md](initialize-keystone.md). |
| 1b | SHARE/datainit `batocera.conf` defaults | `batocera.conf` | stock-ish + hostname SNES on SHARE | From keystone when we apply: `updates.enabled=0`, `global.shaderset=none`, `global.bezel=none`, `system.cec.standby=0`, `es.resolution=max-1920x1080`, `system.cpu.governor=schedutil`, wifi/samba/kodi off. RA pad hotkeys `nul`. |
| 2 | Leftover non-SNES systems | `es_systems.cfg` + `HiddenSystems` | `es_systems` still lists gb/gbc/ports (mesen-s). HiddenSystems already hides them on SHARE. Family stays in the **snes** group, not hidden. | Next image: strip gb/gbc/ports from `es_systems.cfg`. Never `snes.ungroup`. |
| 3 | `sneshd-cart` never starts | `sneshd-cart` / `sneshd-common.sh` | Log: `Critical: no SHARE volume`. No `/run/sneshd/session`. Admin ES works because S11 already mounted SHARE. | Use `blkid -s` (in tree). **Never** run `sneshd-cart start` over SSH (it unmounts SHARE and kills dropbear). Apply via next image or copy files and reboot. |
| 4 | Hostname seed | datainit `batocera.conf` | SHARE is `SNES`. Datainit still `BATOCERA`. `/boot/batocera-boot.conf` has empty `system.hostname=`. | Post-build: datainit `system.hostname=SNES`. Keep boot.conf `SNES`. |
| 5 | ROM launch | Phase 2 exit | Not verified | Play a SNES ROM under bsnes-hd on this box. |
| 6 | Cart session | Phase 3 | No `SNES-*` disk plugged | After #3: admin with no cart (already looks right); then a real cart. |

## Do not do on this box

- Chase DAC / `pcm512x` / HiFi.
- GPIO power/reset, 8bitdo, Leonardo, MSU-1 preload.
- `dd` the production Pimoroni NVMe.
- Rebuild the whole image just to flip ES strings (SHARE `es_settings.cfg` is enough for #1).
