# Mission Control — Handoff

**Owner:** Allison Wi (GitHub: jacksonlakeviewteacher-droid)  
**Repo:** https://github.com/jacksonlakeviewteacher-droid/mission-control-2  
**Hosting:** Cloudflare Pages  
**Live (Production):** branch `release`  
**Default branch:** `main` (dev)  
**Preview Deploys:** any PR/branch ≠ `release`

---

## Branch & Deploy Policy

- Work happens on **feature branches** (e.g., `feature-sharks`, `feature-wallpapers`).  
- Merge **feature → main** when feature is approved (still not live).  
- Publish by PR **main → release** (Cloudflare deploys Production).  
- `release` is **protected**; no direct pushes.

---

## Daily Workflow (both PCs)

```bash
# Start (on either PC)
git checkout feature-<name>
git pull --rebase

# After edits
git add -A
git commit -m "message"
git push`r`n`r`n```bash`r`n- Open PR `feature-<name> → main` for **Preview URL**.  
- When ready to ship: PR `main → release`.

---

## Project Layout (key folders)

```bash`r`n/index.html
/assets/css/...
/assets/js/site.js
/public/sprites/...
/public/wallpapers/...
/public/sounds/...
/public/data/quests.json
/public/data/offline_libraries.json
/public/data/asset_index.json
/tools/*.ps1`r`n`r`n```bash`r`n**Rule:** runtime assets live under `/public`, code under `/assets` or root.

---

## File Naming & Tags

- Lowercase, underscores, no spaces: `bc_quip_start.json`, `enemy_shark_robotic.png`  
- Prefix sets (examples):
  - Bill Cipher images/sfx: `bc_...`
  - Doom Slayer: `ds_...`
  - SFX (generic): `sfx_...`
  - UI icons: `ui_...`
- Image types: UI/transparent → **PNG**, photos/wallpapers → **JPG**  
- JSON keys: `snake_case` (e.g., `quip_text`, `xp_value`)

---

## Next Up (short roadmap)

1. ✅ Confirm branch protections on `release` (and `main` optional).  
2. 🧹 Run file-naming sweep; fix spaces/case.  
3. 🗂️ Regenerate `public/data/asset_index.json` (commit the output).  
4. 🧪 Create `feature-quests-v1`:
   - finalize `quests.json` (6–8 starter quests)
   - wire to `site.js` (load + render list)
   - open PR → review via Cloudflare **Preview**
5. 🚀 When happy: PR `main → release` to publish.

---

## Useful Commands

```bash
# See unpushed commits
git log --oneline origin/main..HEAD

# Show changed files
git status

# Serve locally (PC)
python -m http.server 8000`r`n`r`n```bash`r`n
---

## Contacts / Notes

- Author email for commits: `234073272+jacksonlakeviewteacher-droid@users.noreply.github.com`  
- Keep `release` locked. Publish intentionally only.
