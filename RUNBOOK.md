# Mission Control – RUNBOOK

_Last updated: September 28, 2025_

This runbook lists every script and executable you might run, with **what**, **when**, **where**, and **how**. It assumes this project layout:

```bash`r`nG:\My Drive\Mission-Control-2\         ← source-of-truth for assets you drop in
C:\Dev\Mission-Control-2\              ← mirrored working copy used for local server`r`n`r`n```bash`r`n
> ✅ **Tip:** Prefer **PowerShell 7** (`pwsh`) for all scripts. Our tools auto-hop to `pwsh` if you run them from Windows PowerShell 5.1.

---

## Table of contents

- [Shells you’ll use](#shells-youll-use)
- [One-time setup](#one-time-setup-recommended)
- [Everyday workflow (quick path)](#everyday-workflow-quick-path)
- [Script reference](#script-reference-whatwhenwherehow)
  - [wire_after_upload.ps1](#toolswire_after_uploadps1)
  - [update_paths_assets.ps1](#toolsupdate_paths_assetsps1)
  - [adopt_\*.ps1 (batch movers)](#toolsadoptps1-batch-specific-movers)
  - [ingest_sfx\*.ps1 (SFX importers)](#toolsingest_sfx_and_update_mappingps1-and-friends)
  - [rename_assets.ps1](#toolsrename_assetsps1)
  - [install_pwsh_shim.ps1](#toolsinstall_pwsh_shimps1)
  - [Python indexers](#python-indexers)
  - [Local web server](#local-web-server-preview-site)
- [Where to put assets](#where-to-put-assets)
- [Troubleshooting](#troubleshooting)

---

## Shells you’ll use

- **Prefer PowerShell 7** (`pwsh`). Faster JSON and modern features.
- Windows PowerShell **5.1** still works; our patched scripts will **auto-hop to pwsh** when available.

If scripts ever complain about policy:`r`n`r`n```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`r`n`r`n```bash`r`n
---

## One-time setup (recommended)

Run these once after the tools are present:

```powershell
# Patches all /tools scripts to auto-prefer pwsh and use -AsHashtable on PS7+
pwsh -File "G:\My Drive\Mission-Control-2\tools\install_pwsh_shim.ps1"`r`n`r`n```bash`r`n
This adds a small header to each `/tools/*.ps1`:
- If launched from Windows PowerShell 5.1, it **re-invokes** itself under `pwsh`.
- JSON reads use `ConvertFrom-Json -AsHashtable` on PS7+, with a PS5.1-safe fallback.

---

## Everyday workflow (quick path)

1. **Drop or copy assets** to `G:\My Drive\Mission-Control-2\public\...`
   - images → `public\sprites\...`
   - wallpapers → `public\wallpapers\`
   - overlays → `public\overlays\`
   - sounds → `public\sounds\sfx\`
2. **Mirror & auto-wire (optional):**
   - Run `wire_after_upload.ps1` (see below) to mirror to `C:\Dev` and refresh mappings.
3. **Rebuild indexes** (if not done by the script):
   ```powershell
   py -3 "C:\Dev\Mission-Control-2\tools\build_asset_index.py"
   py -3 "C:\Dev\Mission-Control-2\tools\build_sounds_index.py"
   ```bash`r`n4. **Serve locally:**
   ```powershell
   cd "C:\Dev\Mission-Control-2"
   py -3 -m http.server 8000 -d public
   ```bash`r`n   - Open http://localhost:8000
   - Stop server: **Ctrl + C** (or open a new tab to keep working)

---

## Script reference (what/when/where/how)

### `tools\wire_after_upload.ps1`
- **What:** Mirror **G:\\public → C:\\Dev\\public**, rebuild indexes, auto-wire icons/wallpapers/overlays into `public\data\paths_assets.json`, and add `<html lang="…">` + `<meta name="path-key">` / `<meta name="overlay">` to pages you choose.
- **When:** After a big upload (or at the end) to refresh everything in one go.
- **Run from:** Anywhere.
- **Commands:**`r`n`r`n```powershell
# Preview only (shows actions + JSON to be written)
pwsh -File "G:\My Drive\Mission-Control-2\tools\wire_after_upload.ps1" -Preview

# Apply with specific page defaults
pwsh -File "G:\My Drive\Mission-Control-2\tools\wire_after_upload.ps1" `
     -MetaFiles @("public\tools\portal-demo.html","public\index.html") `
     -PathKey "sharklab" -Overlay "glitch" -Lang "en"`r`n`r`n```bash`r`n- **Output:** Updated `/public/data/paths_assets.json` on **C:** and metas added/updated in your listed pages.

---

### `tools\update_paths_assets.ps1`
- **What:** Mirror sprites/wallpapers/overlays G:→C:, rebuild image index, and refresh **specific** mapping entries based on the base filenames you configure in the script.
- **When:** You swapped a few “hero” artwork files or overlays and want those keys updated.
- **Run from:** Anywhere.
- **Commands:**`r`n`r`n```powershell
# Dry run + (optional) patch Python indexer URLs
pwsh -File "G:\My Drive\Mission-Control-2\tools\update_paths_assets.ps1" -Preview -FixIndexer

# Apply
pwsh -File "G:\My Drive\Mission-Control-2\tools\update_paths_assets.ps1" -FixIndexer`r`n`r`n```bash`r`n
---

### `tools\adopt_*.ps1` (batch-specific movers)
- **What:** Move/rename a specific **batch** (e.g., VR/Sharks, Lava/Vortex, Treasures/Nightmare) into the right `public\...` subfolders, mirror to C:, rebuild indexes, and write sensible defaults into `paths_assets.json`.
- **When:** Immediately after you drop that batch of 10 so you can preview it live.
- **Run from:** Anywhere.
- **Examples:**`r`n`r`n```powershell
# VR/Sharks
pwsh -File "G:\My Drive\Mission-Control-2\tools\adopt_vr_shark_batch.ps1" -Preview
pwsh -File "G:\My Drive\Mission-Control-2\tools\adopt_vr_shark_batch.ps1"

# Lava/Vortex
pwsh -File "G:\My Drive\Mission-Control-2\tools\adopt_lava_vortex_batch.ps1" -Preview
pwsh -File "G:\My Drive\Mission-Control-2\tools\adopt_lava_vortex_batch.ps1"

# Treasures + Nightmare
pwsh -File "G:\My Drive\Mission-Control-2\tools\adopt_treasures_and_nightmare.ps1" -Preview
pwsh -File "G:\My Drive\Mission-Control-2\tools\adopt_treasures_and_nightmare.ps1"`r`n`r`n```bash`r`n
---

### `tools\ingest_sfx_and_update_mapping.ps1` (and friends)
- **What:** Find listed SFX anywhere under **G:**, move into `public\sounds\sfx`, mirror to **C:**, rebuild `sounds_index.json`, and **merge** sound assignments into `paths_assets.json` (non-destructive).
- **When:** After uploading a group of sound effects.
- **Run from:** Anywhere.
- **Commands (example):**`r`n`r`n```powershell
pwsh -File "G:\My Drive\Mission-Control-2\tools\ingest_sfx_and_update_mapping.ps1" -Preview
pwsh -File "G:\My Drive\Mission-Control-2\tools\ingest_sfx_and_update_mapping.ps1"`r`n`r`n```bash`r`n- **Note:** Keeps your `sfx_*` names; run the rename plan later if you want stricter naming.

---

### `tools\rename_assets.ps1`
- **What:** End-of-project **global rename** under `public\sprites` (and optionally `public\sounds`). Generates a **plan CSV/JSON** first; you review, then apply; includes **Undo**.
- **When:** After the final upload batch, before shipping or sharing widely.
- **Run from:** Repo root on **C:** or **G:**.
- **Commands:**`r`n`r`n```powershell
# Preview (writes tools\rename_plan.csv & .json)
pwsh -File tools\rename_assets.ps1

# Apply all proposed renames
pwsh -File tools\rename_assets.ps1 -Apply

# Undo the last applied plan
pwsh -File tools\rename_assets.ps1 -Undo

# Include audio in the pass
pwsh -File tools\rename_assets.ps1 -IncludeAudio -Apply`r`n`r`n```bash`r`n- **Output:** Files renamed; `public\data\asset_index.json` rebuilt automatically.

---

### `tools\install_pwsh_shim.ps1`
- **What:** Patches all `tools\*.ps1` to prepend a **pwsh auto-hop** and switch JSON reads to **`-AsHashtable`** on PS7+ (with safe fallback on PS5.1).
- **When:** After adding **new** scripts to `/tools` or when you edit old ones.
- **Run:**`r`n`r`n```powershell
pwsh -File "G:\My Drive\Mission-Control-2\tools\install_pwsh_shim.ps1"`r`n`r`n```bash`r`n- **Note:** Modifies the other scripts in place (idempotent). No need to run daily.

---

## Python indexers

### `tools\build_asset_index.py`
- **What:** Scans `public/sprites/**` → writes `public/data/asset_index.json` (root-relative URLs like `/sprites/...`).
- **When:** Images change (move/rename/add).
- **Run:**`r`n`r`n```powershell
py -3 "C:\Dev\Mission-Control-2\tools\build_asset_index.py"`r`n`r`n```bash`r`n
### `tools\build_sounds_index.py`
- **What:** Scans `public/sounds/**` → writes `public/data/sounds_index.json`.
- **When:** SFX change.
- **Run:**`r`n`r`n```powershell
py -3 "C:\Dev\Mission-Control-2\tools\build_sounds_index.py"`r`n`r`n```bash`r`n
---

## Local web server (preview site)

- **Serve:**`r`n`r`n```powershell
cd "C:\Dev\Mission-Control-2"
py -3 -m http.server 8000 -d public`r`n`r`n```bash`r`n- **Open:** http://localhost:8000  
- **Stop:** **Ctrl + C**  
- **Run in another window and keep a prompt free:**`r`n`r`n```powershell
Start-Process pwsh -ArgumentList '-NoExit -Command cd "C:\Dev\Mission-Control-2"; py -3 -m http.server 8000 -d public'`r`n`r`n```bash`r`n
---

## Where to put assets

On **G:\\My Drive\\Mission-Control-2\\public**:

```bash`r`nsprites\icons\        ← tile icons (PNG/JPG/SVG)
sprites\sharks\       ← shark sprites
sprites\treasures\    ← chests/loot
sprites\portals\      ← vortex/portal art
sprites\misc\         ← everything else
wallpapers\           ← backgrounds
overlays\             ← full-screen transparent FX (PNG/GIF/WEBM)
sounds\sfx\           ← audio files (mp3/wav/ogg)`r`n`r`n```bash`r`n
Scripts mirror these into **C:\\Dev** automatically.

---

## Troubleshooting

- **`pwsh : The term 'pwsh' is not recognized`**
  - Close & reopen the terminal (PATH refresh), or run it directly:
  ```powershell
  & "C:\Program Files\PowerShell\7\pwsh.exe" --version
  ```bash`r`n  - (Optional) Add to PATH for this user:
  ```powershell
  [Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\Program Files\PowerShell\7', 'User')
  ```bash`r`n
- **JSON errors mentioning `-Depth` on ConvertFrom-Json**
  - That switch does **not** exist on Windows PowerShell 5.1. Use `pwsh`, or use our patched scripts (they handle both shells).

- **Browser error `NotAllowedError: play() failed ...`**
  - Click **Start** once on the page to unlock audio (user gesture). Our `site.js` includes this gate already.

- **404 for `/data/asset_index.json`**
  - Run the Python indexer(s) again from **C:\\Dev**:
  ```powershell
  py -3 "C:\Dev\Mission-Control-2\tools\build_asset_index.py"
  ```bash`r`n
- **Robocopy warnings**
  - Usually fine; ensure the destination isn’t locked, and that paths exist.
