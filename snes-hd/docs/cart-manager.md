# Cart manager

Port of `SNES/postshare.sh` into `/usr/bin/sneshd-cart`. Discovery is **BTRFS label**, never `/dev/sda`.

## Boot

1. `S11share` mounts `LABEL=SHARE` on `/userdata` (no 15s wait).
2. `S12populateshare` seeds SHARE, then `sneshd-cart start`.
3. `sneshd-cart` waits up to 3s for a `SNES-*` volume, then:
   - **cart** — RO bind `…/batocera` → `/userdata`, tmpfs host `system`, `SAVES` on `/userdata/saves`, theme cache on `SNES`
   - **admin** — SHARE stays `/userdata`
4. `/boot/force-admin` forces admin even with a cart plugged in.
5. `S13sneshd-cart-scrub` starts an idle RAID1 scrub if `cart_raid=1`.

## Commands

| Command | Role |
|---|---|
| `sneshd-cart start\|stop\|status` | Session |
| `sneshd-save-game-options` | Allowlisted `snes[` / `controllers.*` + gamelist → SAVES |
| `sneshd-reset-game-options` | Delete SAVES custom files |
| `sneshd-reset-system-defaults` | Restore SHARE `batocera.conf` from datainit |
| `sneshd-format-cart --device /dev/sdX --id ADVN [--raid] --yes` | New cart (refuses nvme) |

Yank: udev on `SNES-*` / `SAVES` remove, only when `/run/sneshd/session` is `MODE=cart`.
