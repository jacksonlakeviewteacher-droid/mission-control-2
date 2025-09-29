# tools/build_asset_index.py
# Scan public/** and write public/data/asset_index.json

import json, pathlib

ROOT   = pathlib.Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "public"
OUT    = PUBLIC / "data" / "asset_index.json"

IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg"}
AUDIO_EXTS = {".mp3", ".wav", ".ogg", ".m4a"}

def to_url(p: pathlib.Path) -> str:
    return "/public/" + p.relative_to(PUBLIC).as_posix()

def list_files(folder: pathlib.Path, exts: set[str]) -> list[str]:
    items = []
    if folder.exists():
        for p in folder.rglob("*"):
            if p.is_file() and p.suffix.lower() in exts:
                items.append(to_url(p))
    return sorted(items)

def build():
    data = {
      "icons":        list_files(PUBLIC / "icons",        IMAGE_EXTS),
      "backgrounds":  list_files(PUBLIC / "backgrounds",  IMAGE_EXTS),
      "sprites":      list_files(PUBLIC / "sprites",      IMAGE_EXTS),
      "sfx":          list_files(PUBLIC / "sfx",          AUDIO_EXTS),
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(f"Wrote {OUT}")

if __name__ == "__main__":
    build()
