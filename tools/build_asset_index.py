# tools/build_asset_index.py
# Scan public/sprites/** and write public/data/asset_index.json

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]          # .../Mission-Control-2
PUBLIC = ROOT / "public"
SPRITES = PUBLIC / "sprites"
OUT = PUBLIC / "data" / "asset_index.json"

IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".gif", ".webp"}

def to_url(p: pathlib.Path) -> str:
    # produce web-style URL starting with /public/...
    return "/public/" + p.relative_to(PUBLIC).as_posix()

def list_images(folder: pathlib.Path) -> list[str]:
    items = []
    for p in folder.rglob("*"):
        if p.is_file() and p.suffix.lower() in IMAGE_EXTS:
            items.append(to_url(p))
    return sorted(items)

def build():
    data = {}

    if not SPRITES.exists():
        print(f"[WARN] sprites folder not found: {SPRITES}")
    else:
        # add one key per immediate subfolder (e.g., sharks, treasures)
        for child in sorted(SPRITES.iterdir()):
            if child.is_dir():
                data[child.name] = list_images(child)

        # files directly in /public/sprites go under "_root"
        root_files = []
        for child in sorted(SPRITES.iterdir()):
            if child.is_file() and child.suffix.lower() in IMAGE_EXTS:
                root_files.append(to_url(child))
        if root_files:
            data["_root"] = root_files

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(f"Wrote {OUT}")

if __name__ == "__main__":
    build()
