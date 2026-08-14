# Satellaview protected saves (later phase)

Satellaview **games** ship in v1 (snes9x, `roms/satellaview`). Satellaview **boot** into a specific BS title can take a very long time through BS-X.

A later phase will add **per-game custom saves** that are:

- Made once, for specific Satellaview titles only
- **Protected** — a casual “reset saves”, an empty SRAM, or a corrupt write must not clobber them
- Applied at launch so the player skips the long BS-X walk

This is not the generic `SAVES` bind. It is a small protected store (likely on NVMe `SNES` or a cart-local `satella/` that admin restore cannot overwrite). Do not invent the on-disk format until the cart manager and family systems are in place.
