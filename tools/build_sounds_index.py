import json, pathlib
ROOT   = pathlib.Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "public"
SOUNDS = PUBLIC / "sounds"
OUT    = PUBLIC / "data" / "sounds_index.json"
AUDIO  = {".mp3",".ogg",".wav",".m4a",".aac"}
def to_url(p: pathlib.Path)->str:
    return "/" + p.relative_to(PUBLIC).as_posix()
def build():
    data={}
    if SOUNDS.exists():
        for d in sorted(SOUNDS.iterdir()):
            if d.is_dir():
                files=[to_url(p) for p in sorted(d.rglob("*")) if p.suffix.lower() in AUDIO]
                if files: data[d.name]=files
        root=[to_url(p) for p in sorted(SOUNDS.glob("*")) if p.is_file() and p.suffix.lower() in AUDIO]
        if root: data["_root"]=root
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(f"Wrote {OUT}")
if __name__=="__main__": build()
