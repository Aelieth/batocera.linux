# SNES-HD

Project-owned work for the dedicated SNES console image. This directory is what we commit and iterate on as documentation and notes.

**New session:** start at [`PLAN.md`](PLAN.md). That file is the handoff. Chat is not.

The Batocera/Buildroot pieces **must** stay in the fork’s usual paths so `make sneshd-build` finds them:

| Path | Role |
|---|---|
| `configs/batocera-sneshd.board` | Board defconfig |
| `board/batocera/broadcom/sneshd/` | `config.txt`, genimage, lean S11/S12 |
| `package/batocera/sneshd/` | cart manager, admin tools, `snes-load` theme, SNES-only package set |
| [`assets/`](assets/) | Logos, loading stills, Plymouth theme (project copies) |

Git branch: **`snes-hd_initial`**.

`SNES/` is the old live-system archive (including `rootfs.cpio`). It is gitignored. Do not rsync it into the image.

Docs for disks, carts, Plymouth, Sinden, and Satellaview live in [`docs/`](docs/).  
Art lives in [`assets/`](assets/): logos, loading stills, and the `snes-load` Plymouth theme.
