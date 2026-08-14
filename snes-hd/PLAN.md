# SNES-HD plan (session handoff)

**Read this file first in a new session.** Chat history is not the source of truth.

**Working memory rule:** after every step, update this file — status table, section checkboxes, and **§9 Log**. If it is not written here, it did not happen.

Last updated: 2026-08-14

---

## 0. How to resume

1. Open this file.
2. Skim **1. Status**. Do the next unchecked **implementable** section, not a later-repo item.
3. Hardware and disk rules: [docs/disks.md](docs/disks.md), [docs/hardware.md](docs/hardware.md).
4. Cart session: [docs/cart-manager.md](docs/cart-manager.md).
5. Initramfs / Plymouth: [docs/plymouth.md](docs/plymouth.md).
6. Guns: [docs/sinden.md](docs/sinden.md). Satellaview saves: [docs/satellaview.md](docs/satellaview.md).

Repo: this Batocera fork (`Aelieth/batocera.linux` cloned into the workspace).  
Branch for this work: **`snes-hd_initial`**.  
Archive (gitignored): `SNES/` at repo root. Do not rsync it into the image.

Buildroot-facing paths (must stay where they are):

| Path | Role |
|---|---|
| `configs/batocera-sneshd.board` | Board |
| `board/batocera/broadcom/sneshd/` | Boot files, genimage, lean S11/S12 |
| `package/batocera/sneshd/` | Packages: system, cart, admin, plymouth theme |
| `package/batocera/core/batocera-configgen/configs/configgen-defaults-sneshd.yml` | Default cores |
| `snes-hd/` | Plan, docs, [`assets/`](assets/) (logos, splash, Plymouth) |

Build: `make BATCH_MODE=y PARALLEL_BUILD=y sneshd-build`  
`buildroot/` submodule is initialized (`059038b33a`). First fat image cancelled; strip applied. **Clean baseline image built 2026-08-14 10:42** (not flashed). Artifact: `output/sneshd/images/batocera/images/sneshd/batocera-bcm2712-sneshd-44-20260814.img.gz` (~676M, md5 `ef6fd4bea773daea625ad0bb38c28f3c`). Kernel 6.18 did **not** fail. Stock Batocera initramfs (`initrd.lz4` ~1M), not snes-load yet. SHARE is BTRFS 512M labeled `SHARE`; OS still squash.

---

## 1. Status

Honest gap: Phases 1–3 and the theme lift are **in the tree**, not **on the console**. Nothing has been flashed or timed.

| # | Section | State |
|---|---|---|
| A | Product decisions (locked) | Done |
| B | Phase 0 — spec + docs home | Done (`snes-hd/`) |
| C | Phase 1 — `sneshd` board | **Clean baseline image 20260814 10:42** (BTRFS SHARE, prune, stubs). Not flashed |
| D | Phase 2 — SNES-only + ARM64 BSNES | In image (4 cores built); not hardware-verified |
| E | Phase 3 — cart manager | In tree, not hardware-verified |
| F | Phase 4 — physical console (GPIO, HiFi, MSU-1) | **Next implementable** |
| G | Phase 5 — BTRFS OS root | SHARE-as-BTRFS in tree (transitional); OS still squash |
| H | Phase 6 — thin uClibc initramfs + `snes-load` | Theme lifted; ramdisk not rebuilt |
| I | Phase 7 — boot diet + measure | Needs a real image |
| J | Phase 8 — Sinden / FPS cart | Research done; needs hardware |
| K | Phase 9 — Satellaview protected saves | Later |
| L | Phase 10 — custom kernel | Later, other repo |
| M | Phase 11 — Aelieth GPU bsnes-hd | Later, other repo |

---

## 2. Product (locked)

Do not reopen these unless the owner changes them in writing here.

1. Machine: Pi 5 + Pimoroni NVMe Base + USB3 SSD carts. Not a generic Batocera stick.
2. NVMe is the console. USB SSD labeled `SNES-<id>` is the cartridge.
3. No cart (or `/boot/force-admin`) → admin session on `SHARE`.
4. Valid cart → that cart’s games, theme, music, backgrounds, `SAVES`.
5. Full SNES family: snes, snes-msu1, satellaview, sufami, sgb, sgb-msu1.
6. Frontend: stripped EmulationStation. Cart supplies the experience.
7. Physical SNES shell: GPIO power/reset, Arduino Leonardo pads, InnoMaker HiFi DAC, cart-yank poweroff.
8. Keep **Sinden / guns**. Cut wheels. Dedicated FPS cart carries `controllers.guns.*`.
9. OS libc stays **glibc** (Sinden/Mono). Initramfs libc is **uClibc-ng**.
10. Kernel (`Aelieth/SNES-HD-kernel`) and GPU bsnes-hd (`Aelieth/bsnes-hd`) are **later**. First images: stock Pi 5 6.18 kernel + DerKoun `libretro-bsnes-hd` if it builds.
11. No physical SNES slot. No mid-session cart hot-swap. No `/dev/sda` hardcoding.
12. Existing `SNES-*` disks from the last machine must still mount.
13. Keep Batocera **management scripts** (`BATOCERA_SCRIPTS`, `BATOCERA_SETTINGS`, `BATOCERA_RESOLUTION`, `BATOCERA_IMAGE`). They assume squash overlay today (`batocera-save-overlay`, `batocera-upgrade`, `batocera-install`, `batocera-sync`, `batocera-part`, …). **Do not cut them because they will break on BTRFS.** Adapt them in Phase 5/7 as we go.
14. Build failures from our cuts are expected. The **kernel will almost certainly fail** (Batocera injections vs stock 6.18 / later custom kernel). Adapt. **Ask the owner before any major decision** (re-enable a cut family, change kernel source, grow initramfs, flip libc, rewrite upgrade/overlay, restart a full image after a policy change). Diagnose first; do not invent a fix path and run it.

---

## 3. Proven layout (from `SNES/` archive)

Details: [docs/disks.md](docs/disks.md).

```
nvme0n1  Pimoroni NVMe
  p1  FAT     BATOCERA     firmware + kernel + initrd
  p2  BTRFS   SHARE        admin userdata  → /media/SHARE  (/userdata if no cart)
  p3  BTRFS   SNES         extras, theme cache → /media/SNES

USB SSD cart
  p1  BTRFS   SNES-<id>    RO library → /media/SNES-<id>/batocera bind /userdata
  p2  BTRFS   (optional RAID1 pair of p1, same UUID)
  p3  BTRFS   SAVES        RW saves + batocera-custom.conf + gamelist-custom.xml
```

Binds in a cart session: RO cart userdata, tmpfs copy of SHARE `system` over `/userdata/system`, SAVES over `/userdata/saves`, cached themes from `/media/SNES/carts/<id>/`. Allowlist merge: `snes[` and `controllers.*` only.

---

## 4. Boot budget

Wall-clock goal: **power → ES < 10s** (NVMe + cart already in, 1080p).

1. Pi EEPROM + HDMI handshake is often **~8s** on a TV. First `snes-load` converge is frequently missed. **That is OK.**
2. Initramfs must be ready when HDMI appears. Size class: `SNES/rootfs.cpio` (~12M lz4 / 26M uncompressed).
3. Every extra MB in the ramdisk is milliseconds after handshake.
4. The 172M glibc `rootfs.cpio` at repo root is the **anti-pattern** (gitignored). Do not copy it.

---

## 5. Sections (do one at a time)

### A. Product decisions

- [x] Locked in this file, section 2.

### B. Phase 0 — spec home

- [x] `SNES/` is reference only; gitignored.
- [x] Project docs live in `snes-hd/` (this folder).
- [ ] First real commit of `snes-hd/` + board/package paths (not done yet).

### C. Phase 1 — board

- [x] `configs/batocera-sneshd.board` (BCM2712 kernel, hostname SNES, images → `broadcom/sneshd`).
- [x] `board/batocera/broadcom/sneshd/` from archive `config.txt` / `cmdline.txt` (PCIe, DAC, underclock, Wi‑Fi/BT off).
- [x] `make sneshd-build` produces an image. *(2026-08-14 `batocera-bcm2712-sneshd-44-20260814.img.gz`)*
- [ ] Image boots from Pimoroni NVMe.
- [ ] `blkid` sees an existing `SNES-*` USB disk.

**Exit:** stock-enough ES on the real Pi 5 from NVMe.

### D. Phase 2 — SNES-only + BSNES

- [x] `BR2_PACKAGE_BATOCERA_SNESHD` (ALL_SYSTEMS=n, Kodi=n).
- [x] Cores: bsnes, **bsnes-hd**, snes9x, mesen-s.
- [x] Defaults in `configgen-defaults-sneshd.yml` (bsnes_hd for snes / msu1 / sgb-msu1).
- [x] Mode 7 **3x**, widescreen off — `package/batocera/sneshd/sneshd-system/retroarch-core-options.cfg`.
- [x] Slim `S12populateshare` on this board.
- [x] Guns: `BATOCERA_GUNS` umbrella gated off; `sneshd-system` selects Sinden + precalibrations only.
- [x] Image built (bsnes, bsnes-hd, snes9x, mesen-s all installed). Six family systems not hardware-checked.
- [ ] A ROM launches under bsnes-hd.

**Exit:** SNES-only ES, ARM64 bsnes-hd plays.

### E. Phase 3 — cart manager

- [x] `sneshd-cart`: label discovery, 3s USB wait, admin vs cart, tmpfs system, allowlist merge, theme cache, gamelist bind.
- [x] `sneshd-save-game-options` + Python ElementTree gamelist (not sed).
- [x] Yank udev (`SNES-*` / `SAVES`) only when `MODE=cart`.
- [x] RAID1 idle scrub `S13`.
- [x] `sneshd-format-cart` (refuses nvme), reset game/system tools.
- [x] Lean `S11share` (LABEL=SHARE, no 15s wait).
- [ ] No SSD → admin ES on SHARE (hardware).
- [ ] Existing `SNES-ADVN`-style cart plays with its theme and saves.
- [ ] Yank USB → hard poweroff. Reboot without cart → admin, SHARE intact.
- [ ] `/boot/force-admin` forces admin with a cart inserted.

**Exit:** last machine’s carts work without `/boot/postshare.sh`.

### F. Phase 4 — physical console  ← do this next unless jumping to H

Archive scripts: `SNES/powerswitch.py`, `HiFi_audio.py`, `msu1_preload.py`, `99-8bitdo-controller.rules`.

- [ ] `sneshd-powerswitch`: BCM 8 shutdown, BCM 15 reset (`lgpio`). Short reset = emukill; long reset = optional save then reboot.
- [ ] `sneshd-hifi`: InnoMaker DAC vs HDMI (`allo-boss-dac-pcm512x-audio` already in `config.txt`). Port the working Python; do not rewrite Batocera audio.
- [ ] 8bitdo rules + Leonardo HID (stock kernel).
- [ ] Network (connman/dropbear/ntp) gated off unless admin enables them.
- [ ] `sneshd-msu1`: ES game-start/end preload/cleanup from the archive.

**Exit:** front-panel power/reset match the last console; DAC/HDMI switch works; MSU-1 starts without the old stutter.

### G. Phase 5 — BTRFS OS root

- [x] Transitional: genimage SHARE is BTRFS (`userdata.btrfs`, 512M seed). OS still squash. `S02resize` grows BTRFS on `autoresize=true`.
- [ ] Board genimage: FAT boot (can shrink later) + BTRFS with SHARE / SNES labels kept.
- [ ] Root is a BTRFS subvolume, not squash. Updates via snapshots, not `.update` squash.
- [ ] Mount happens **inside the Phase 6 thin initramfs** (btrfs tools live there).

**Exit:** no `boot/batocera` squash file; carts and SHARE unchanged.

### H. Phase 6 — thin uClibc initramfs + snes-load

Source: `SNES/rootfs.cpio` (gitignored). Theme already lifted to `package/batocera/sneshd/sneshd-plymouth/`.

- [x] `snes-load` script, pngs, `plymouthd.conf` in git.
- [x] Archive test `init` saved as `sneshd-plymouth/reference/init.snes-archive` (ends in `/bin/sh` — not production).
- [ ] Separate **uClibc-ng** link for the ramdisk. Do **not** use Batocera `TARGET_CC` (glibc).
- [ ] Allowlist only: plymouthd + `script.so` + drm/fb, `snes-load` (no stock themes), busybox, btrfs tools, `pcie-brcmstb` + `nvme` + `xhci-*`.
- [ ] Production `init`: plymouthd **before** NVMe/USB modprobe; then `switch_root` after `display_logo`.
- [ ] Status protocol: `busy=1|0`, `switch_root=1`, `animate_expand=1`, `display_logo=1`.
- [x] Drop `BR2_PACKAGE_BATOCERA_SPLASH_MPV` on this board (static `SPLASH_IMAGE` until Plymouth ramdisk).
- [x] Archive SNES stills installed as image-splash (no `convert`). Plymouth last-frame match is later.
- [ ] Ramdisk stays in the ~12M lz4 class.

**Exit:** `snes-load` from the moment HDMI is up; `switch_root` into root; no kernel text; no mpv.

### I. Phase 7 — measure

- [ ] Time EEPROM, handshake, initramfs, cart binds, ES on the real TV and on a monitor.
- [ ] Drop leftover `S*` on this board.
- [ ] Only then consider deleting unused Batocera boards from the working tree.

### J. Phase 8 — Sinden / FPS cart

- [x] Host keeps `BATOCERA_GUNS` / Sinden / Mono / v4l. CSI camera overlay stays disabled (Sinden is USB UVC).
- [x] Cart merge already allowlists `controllers.*`.
- [ ] Hardware: Sinden enumerates with Wi‑Fi/BT off.
- [ ] Borders work under labwc + Super Scope titles.
- [ ] Yank rules do not fire on Sinden USB video reconnects.
- [ ] A `SNES-*` guns cart carries `controllers.guns.*` on SAVES.

### K. Phase 9 — Satellaview protected saves

- [ ] Per-game SRAM/saves for specific BS titles only.
- [ ] Protected: reset-saves / empty SRAM cannot clobber them.
- [ ] Applied at launch so the player skips the long BS-X walk.
- [ ] Not the generic SAVES bind. Design after E and D work on hardware.

### L. Phase 10 — kernel (other repo)

- [ ] Rebase old 6.6 PCIe-Gen3 work onto 6.18.
- [ ] Point `batocera-sneshd.board` at an `Aelieth/SNES-HD-kernel` tag.
- [ ] Until then: stock `raspberrypi/linux` 6.18.

### M. Phase 11 — Aelieth bsnes-hd (other repo)

- [ ] Retarget `libretro-bsnes-hd.mk` when GPU work exists.
- [ ] Until then: DerKoun pin, default 3x Mode 7, widescreen off.

---

## 6. Do not

1. Commit `SNES/` or `*.cpio`.
2. Flip the OS to uClibc-ng.
3. Grow the initramfs “just in case.”
4. Hardcode `/dev/sda`.
5. Bind the whole cart read-write.
6. Parse gamelist XML with sed.
7. Rewrite HiFi from scratch.
8. Invent a cart format that cannot mount existing `SNES-*` disks.
9. Drop Sinden to save packages.
10. Block play on the custom kernel or Aelieth GPU core.

---

## 7. Incoming dumps

When more old-system files show up, record them here so the next session sees them:

| Date | What | Where it lives | Action |
|---|---|---|---|
| 2026-08-14 | Working uClibc initramfs | `SNES/rootfs.cpio` (ignored) | Theme extracted to `package/batocera/sneshd/sneshd-plymouth/` |
| 2026-08-14 | Fat glibc experiment | `rootfs.cpio` repo root (ignored) | Do not use as a model |

---

## 10. What the live `.config` still builds (2026-08-14, post-strip)

Source: `output/sneshd/.config` after `make BATCH_MODE=y sneshd-config`.  
**828** `BR2_PACKAGE_*=y` (was ~1104, then 812 before putting Control Center + pacman back). Still **5 libretro packages** (core-info + 4 cores). SNESHD guards remain for everything else. Stock bcm2712 is unchanged.

### Intentionally kept

- RetroArch, `libretro-bsnes`, `libretro-bsnes-hd`, `libretro-snes9x`, `libretro-mesens`
- ES + labwc + Mesa VC4 + Vulkan (Pi 5 path; bezels for Sinden borders)
- **Sinden only**: `SINDEN_GUNS` + libs + precalibrations + Mono + libv4l + evsieve (Mono is why OS stays glibc)
- PipeWire / ALSA (HiFi DAC later)
- `python3-gpiod` / `libgpiod2` (powerswitch)
- Btrfs tools, connman/dropbear (admin, gated at runtime)
- **Management scripts** (always keep): `BATOCERA_SCRIPTS`, `BATOCERA_SETTINGS`, `BATOCERA_RESOLUTION`, `BATOCERA_IMAGE`. Overlay/upgrade/install/sync will be rewritten for BTRFS later, not deleted.
- **Control Center** + **pacman** (owner: keep). ES Web UI and Samba/Avahi stay off.
- `BATOCERA_TOOLS` (vim/nano/htop/evtest — SSH admin)
- Pi wifi firmware (`BRCMFMAC_*` only; `ALLLINUXFIRMWARES` is off)

### Init scripts on this board (2026-08-14)

Stock `S*` come from `board/batocera/fsoverlay` + packages. Board overlay wins.

| Script | Action |
|---|---|
| `S11share` / `S12populateshare` / `S65values4configtxt` | Lean replacements (already) |
| `S02resize` | BTRFS grow on `autoresize=true` |
| `S91smb` / `S97joycond` / `S31sixad` | Exit 0 if binary missing |
| `S25lircd` / `S12mergerfs` | Already skip if unused |
| `S08connman` / `S26system` / ES / audio | Keep |

**Not in this image:** `vpinball`, `vita3k`, `smbd`, `joycond`, `/usr/sixad`.  
**Datainit in this image:** SNES family only (`snes`, `snes-msu1`, `satellaview`, `sufami`, `sgb`, `sgb-msu1`). Pruned: `kodi/`, `system/.kodi/`, `roms/ports`, `roms/gb`, `roms/gbc` (post-build, after per-package rsync). Empty FHS dirs (`/opt`, `/media`, `/proc`) stay — required. Configgen still contains unused generator `.py` files (one package).

### Cut this pass (guards or board last-wins)

mpv splash, RPI_HEVC, GStreamer video-codecs, espeak, NFS, extras umbrella, DMD/backglass/rust-dmd, all wheels, Xbox/Switch extras, full `BATOCERA_GUNS` family, Pironman5/Picade/retrogame/wm8960, Samba/Avahi/mosquitto/torrent/NFC/syncthing, desktopapps/GTK/pcmanfm, box64, WireGuard, all-linux-firmwares, LIRC, LEDSpicer, innoextract, ES web UI, music-support.

### Still on — next careful cuts only if needed

Do **not** comment these out in upstream `Config.in`. Gate with `if !BR2_PACKAGE_BATOCERA_SNESHD` or a board-local select.

| Still =y | Why it is on | Cut risk |
|---|---|---|
| **Bluetooth stack** | SYSTEM | `config.txt` disables BT. Keep until powerswitch/pads prove they do not need it. |
| **XWayland** | board file | ES/labwc may still want it. Do not cut until a Wayland-only ES is proven. |
| **SDL3** | SYSTEM | Harmless extra unless it fails the build. |
| **host-qemu** | `gobject-introspection` (glib) | **Host only**, not on the Pi. GIR needs it to cross-build. |
| **host-rustc** | **evsieve** (Sinden) | Host only, but slow. Cannot drop without replacing evsieve. DMD/wheels no longer pull it. |
| **FFMPEG** | ES / PipeWire path | Not mpv. Leave unless a later profile proves ES works without it. |
| **CRYPTSETUP / NTFS / exFAT / CIFS / mergerfs** | SYSTEM “minimal” | Carts are BTRFS; boot is FAT. CIFS is cited as boot-mount. Probe S11 before cutting. |
| **LIBCEC** | HDMI-CEC | Nice-to-have for the TV. Not required. |
| **BOOST_ATOMIC / BOOST_REGEX** unmet deps | SYSTEM selects them without `BR2_PACKAGE_BOOST` | Pre-existing Batocera warning, not ours. Watch the first compile. |

### How we will patch when something breaks

1. Stop. Show the owner the failing package, the missing symbol/file, and two options if there is a real choice. **Do not pick a major path alone.**
2. Prefer `if !BR2_PACKAGE_BATOCERA_SNESHD` around a `select` in `batocera-system/Config.in`, or extra `select`s in `sneshd-system`. Never delete a package from the tree.
3. Check who else `select`s it (grep Config.in) and what runtime path ES/configgen/udev expects.
4. If a script still calls a missing binary, keep the package or stub the script on this board only — after asking if that is more than a one-line restore.
5. Rebuild the single package / defconfig — do not restart the whole world unless the toolchain flag changed.
6. Kernel: expect Batocera patches/injections to disagree with this board’s 6.18 tarball (and later with `SNES-HD-kernel`). Quote the error; do not swap kernel trees or drop patches without asking.

---

## 8. Next session prompt (copy)

```
Continue SNES-HD from snes-hd/PLAN.md. Read §1 Status, §2 rule 14, and §9 Log first.
Expect cut- and kernel-related build failures. Diagnose, then ask before
any major decision. Update PLAN.md after every step. Chat is not memory.
```

---

## 9. Log

Newest first. One line per accomplishment or failed attempt.

| When | What |
|---|---|
| 2026-08-14 | Branch **`snes-hd_initial`**: first commit of board, packages, scripts, docs, and `snes-hd/assets/{logos,splash,plymouth}`. Archive `SNES/` and `*.cpio` stay gitignored. |
| 2026-08-14 | **Clean baseline image built** 10:42: `output/sneshd/images/batocera/images/sneshd/batocera-bcm2712-sneshd-44-20260814.img.gz` (~676M, md5 `ef6fd4bea773daea625ad0bb38c28f3c`). Uncompressed 6980370432: FAT 6GiB + BTRFS SHARE 512MiB label `SHARE` (`_BHRfS_M`). squash 656M, Image 25M, initrd.lz4 1.0M. Datainit: SNES family only. Not flashed. |
| 2026-08-14 | First post-image-fixed rebuild produced an image, but datainit prune in `sneshd-system.mk` lost to per-package rsync. Moved prune to `post-build-script.sh` (SNESHD-gated). Rebuilt. |
| 2026-08-14 | Clean baseline rebuild **restarted** after post-image fix. Log `/tmp/sneshd-build.log`. |
| 2026-08-14 | Clean baseline rebuild **failed** at post-image: comment in `sneshd/genimage.cfg` contained the vfat placeholder token, so sed dumped a second `file { }` list at top level (`genimage.cfg:472: no such option 'file'`). mkfs.btrfs zoned ERROR was a non-fatal stat of a missing output file (512M SHARE still written). Fix: substitute only a standalone placeholder line; `truncate -s 512M` before mkfs. |
| 2026-08-14 | Clean baseline rebuild **started**: `make BATCH_MODE=y PARALLEL_BUILD=y sneshd-build`. BTRFS SHARE, init stubs, datainit prune, splash stills. Log `/tmp/sneshd-build.log`. |
| 2026-08-14 | Init/package audit. VPinball **not** in image (`STRIP_EXCLUDE_DIRS` leftover cleared). Only 4 SNES cores. Overlay skip-if-missing: `S91smb`, `S97joycond`, `S31sixad`. `S02resize` grows BTRFS SHARE. genimage SHARE → `userdata.btrfs`. Prune datainit `kodi` / `ports` / `gb` / `gbc` on next `sneshd-system` install. First `.img.gz` still has ext4 SHARE + those seed dirs. |
| 2026-08-14 | First thinner **image built**: `output/sneshd/images/batocera/images/sneshd/batocera-bcm2712-sneshd-44-20260814.img.gz` (~676M). `rootfs.squashfs` 657M. Kernel `Image` 25M (6.18 stock, no fail). `initrd.lz4` 1.0M (stock Batocera ramdisk). Cores: bsnes, bsnes-hd, snes9x, mesen-s. Not flashed. |
| 2026-08-14 | Owner: use current archive splash stills; Plymouth match later. Lifted `SNES/CustomSNES/.../splash/` into `sneshd-plymouth/splash/`. SNESHD `INSTALL_IMAGE` copies them (no `convert`). Resumed build. |
| 2026-08-14 | `cargo-c` installed. Next fail: `batocera-splash` image path calls host `convert` (ImageMagick); not in Docker PATH, `HOST_IMAGEMAGICK` unset. Stock boards use mpv so they never hit this. Ask owner. |
| 2026-08-14 | `cargo-c` **built** with `--ignore-rust-version`; `cargo install` still hit kstring MSRV. Added the same flag to `HOST_CARGO_C_CARGO_INSTALL_OPTS`. Resumed. |
| 2026-08-14 | Owner: keep GTK / `gtk-layer-shell` / `batocera-bezel-overlay` (Sinden borders on top). Added `HOST_CARGO_C_CARGO_BUILD_OPTS=--ignore-rust-version` (kstring 2.0.4 MSRV 1.96 vs rust-bin 1.95). Resumed build. |
| 2026-08-14 | Option 1 insufficient: `host-cargo-c` still built. Real chain is Wayland `gtk-layer-shell` → `LIBGTK3=y` → `host-librsvg` → `host-cargo-c`. Same rustc 1.95 / kstring 1.96. |
| 2026-08-14 | Owner: option 1. Removed 97 leftover `output/sneshd/build/*` dirs + 77 per-package dirs (`host-cargo-c`, `librsvg`, gated fat). Resumed `sneshd-build`. |
| 2026-08-14 | Build **stopped** (~4.5 min): `host-cargo-c v0.10.19` Error 101. `rustc 1.95.0` vs `kstring@2.0.4` wants 1.96. `LIBRSVG`/`LIBDOVI` unset in current `.config`; leftover dirs from cancelled fat run. No image. |
| 2026-08-14 | Thinner `sneshd` build **started**: `make BATCH_MODE=y PARALLEL_BUILD=y sneshd-build`. 828 packages. Log `/tmp/sneshd-build.log`. Failures from cuts/kernel expected; stop and ask. |
| 2026-08-14 | Policy: cuts and kernel will fail; adapt. Ask owner before any major decision (re-enable families, kernel tree/patches, initramfs/libc, overlay rewrite, full-image restart after policy change). |
| 2026-08-14 | Owner: keep Control Center + pacman; leave ES Web UI and Samba/Avahi off. Ungated those two selects. `sneshd-config` → **828** packages. |
| 2026-08-14 | Policy: keep Batocera management scripts; adapt overlay/upgrade/install/sync for BTRFS later. Do not cut `BATOCERA_SCRIPTS`/`SETTINGS`/`RESOLUTION`/`IMAGE`. |
| 2026-08-14 | SYSTEM strip applied (~95 SNESHD guards). `sneshd-system` selects Sinden + precalibrations. Board: image splash, no HEVC/mpv/video-codecs/espeak/NFS/extras. `make BATCH_MODE=y sneshd-config` → **812** packages (was 1104). Sinden/Mono/evsieve/4 cores stay =y. host-rustc remains via evsieve. Image **not** restarted. See §10. |
| 2026-08-14 | First `sneshd` build **cancelled** on request (Docker stopped) so the remaining SYSTEM fat could be gated before more compile time. |
| 2026-08-14 | Reviewed live `output/sneshd/.config`: ALL_SYSTEMS off, only 4 SNES cores + RetroArch. SYSTEM umbrella still pulled Samba, Mono+all guns, DMD/Rust, mpv splash, HEVC, Pironman5, wheels, backglass, torrent, NFC, desktop apps. Host QEMU is from gobject-introspection (build-only). |
| 2026-08-14 | `buildroot` submodule initialized at `059038b33a`. |
| 2026-08-14 | Convention: this file is working memory. Update it at every step. |
