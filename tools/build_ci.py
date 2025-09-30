# tools/build_ci.py
# Builds:
#  - assets/manifest.json  (inventory for editors/tools)
#  - public/data/asset_index.json  (sprites/images for the site)
#  - public/data/sounds_index.json (sounds for the site)

import json, pathlib

ROOT   = pathlib.Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
PUBLIC = ROOT / "public"
DATA   = PUBLIC / "data"
DATA.mkdir(parents=True, exist_ok=True)

IMG = {".png",".jpg",".jpeg",".gif",".webp",".svg"}
AUD = {".mp3",".wav",".ogg",".m4a",".flac"}

def rel(p: pathlib.Path, base: pathlib.Path) -> str:
    return p.relative_to(base).as_posix()

# 1) assets/manifest.json (images+audio from assets/ and public/*)
scan = []
for sub in ["assets", "public/sprites", "public/overlays", "public/wallpapers", "public/sounds", "public/icons"]:
    p = ROOT / sub
    if p.exists(): scan.append(p)

items = []
for base in scan:
    for p in base.rglob("*"):
        if not p.is_file(): continue
        ext = p.suffix.lower()
        kind = "image" if ext in IMG else "audio" if ext in AUD else None
        if not kind: continue
        rel_repo = rel(p, ROOT)
        tags = list(pathlib.Path(rel_repo).parent.parts) + [p.stem]
        items.append({
            "id": "".join(ch if ch.isalnum() else "_" for ch in p.stem).lower(),
            "path": rel_repo,
            "kind": kind,
            "ext": ext.lstrip("."),
            "tags": [t for t in tags if t]
        })

(ASSETS / "manifest.json").parent.mkdir(parents=True, exist_ok=True)
(ASSETS / "manifest.json").write_text(json.dumps(items, indent=2), encoding="utf-8")

# 2) public/data/asset_index.json (images under public/sprites/** grouped by top folder)
SPRITES = PUBLIC / "sprites"
img_index = {}
if SPRITES.exists():
    for child in sorted(SPRITES.iterdir()):
        if child.is_dir():
            coll = []
            for p in child.rglob("*"):
                if p.is_file() and p.suffix.lower() in IMG:
                    coll.append("/public/" + rel(p, PUBLIC))
            if coll: img_index[child.name] = sorted(coll)
    # root-level sprite files
    root_files = ["/public/" + rel(p, PUBLIC)
                  for p in SPRITES.iterdir()
                  if p.is_file() and p.suffix.lower() in IMG]
    if root_files:
        img_index["_root"] = sorted(root_files)

(DATA / "asset_index.json").write_text(json.dumps(img_index, indent=2), encoding="utf-8")

# 3) public/data/sounds_index.json (public/sounds/**)
SOUNDS = PUBLIC / "sounds"
snd_index = {}
if SOUNDS.exists():
    for child in sorted(SOUNDS.iterdir()):
        if child.is_dir():
            coll = []
            for p in child.rglob("*"):
                if p.is_file() and p.suffix.lower() in AUD:
                    coll.append("/public/" + rel(p, PUBLIC))
            if coll: snd_index[child.name] = sorted(coll)
    # root-level
    root_files = ["/public/" + rel(p, PUBLIC)
                  for p in SOUNDS.iterdir()
                  if p.is_file() and p.suffix.lower() in AUD]
    if root_files:
        snd_index["_root"] = sorted(root_files)

(DATA / "sounds_index.json").write_text(json.dumps(snd_index, indent=2), encoding="utf-8")

print("Wrote:",
      ASSETS / "manifest.json",
      DATA / "asset_index.json",
      DATA / "sounds_index.json")
