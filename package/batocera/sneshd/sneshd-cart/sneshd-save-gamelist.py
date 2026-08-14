#!/usr/bin/env python3
"""Merge ES recovery XML into SAVES/gamelist-custom*.xml (ElementTree, not sed)."""

from __future__ import annotations

import sys
import xml.etree.ElementTree as ET
from datetime import datetime
from pathlib import Path

LOG = Path("/tmp/save_game_options.log")

FAMILY = (
    ("snes", "gamelist-custom.xml"),
    ("snes-msu1", "gamelist-custom-snes-msu1.xml"),
    ("satellaview", "gamelist-custom-satellaview.xml"),
    ("sufami", "gamelist-custom-sufami.xml"),
    ("sgb", "gamelist-custom-sgb.xml"),
    ("sgb-msu1", "gamelist-custom-sgb-msu1.xml"),
)


def log(msg: str) -> None:
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with LOG.open("a") as fh:
        fh.write(f"[{ts}] {msg}\n")


def update_one(original: Path, recovery_dir: Path, output: Path) -> bool:
    if not original.is_file():
        log(f"No gamelist at {original}")
        return False
    tree = ET.parse(original)
    root = tree.getroot()
    if not recovery_dir.is_dir():
        log(f"No recovery dir {recovery_dir}")
        return False

    updated = False
    for recovery_file in recovery_dir.iterdir():
        if recovery_file.suffix != ".xml":
            continue
        try:
            recovery_root = ET.parse(recovery_file).getroot()
            new_game = recovery_root.find(".//game")
            if new_game is None:
                continue
            new_path = new_game.find("path")
            if new_path is None or new_path.text is None:
                continue
            game_path = new_path.text
            for game in list(root.findall("game")):
                path = game.find("path")
                if path is not None and path.text == game_path:
                    root.remove(game)
                    break
            root.append(new_game)
            updated = True
            log(f"Updated {game_path} from {recovery_file}")
        except ET.ParseError as exc:
            log(f"Parse error {recovery_file}: {exc}")

    if updated:
        output.parent.mkdir(parents=True, exist_ok=True)
        tree.write(output, encoding="utf-8", xml_declaration=True)
        log(f"Wrote {output}")
    return True


def main() -> int:
    saves = Path("/media/SAVES")
    ok = True
    for system, dest_name in FAMILY:
        original = Path(f"/userdata/roms/{system}/gamelist.xml")
        recovery = Path(f"/userdata/system/configs/emulationstation/recovery/{system}")
        if not original.is_file() and not recovery.is_dir():
            continue
        if not update_one(original, recovery, saves / dest_name):
            ok = False
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
