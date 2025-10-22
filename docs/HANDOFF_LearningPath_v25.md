[PASTE THE HANDOFF_LearningPath_v25.md CONTENTS HERE]# Mission Control — Learning Path (v25 Hand-off)
**Theme:** Blue / Grey / Gold / Black  
**Mode:** Preview-only (production frozen)

## What’s Included
- `public/data/paths.json` — top-level curriculum (VR → Engine → Bedrock → Java).
- `public/js/quip.js` — Bill Cipher overlay (pop-up quips; URL toggle `?quip=0`).
- `public/quests.html` (existing or to-be-added) — renders quests grid from JSON.
- `docs/DEV_GUIDE.md`, `docs/FLOW.md` — unchanged; referenced by Setup module.

## Learning Path (high-level)
1. **Setup & Safe Sync (grey)** — VS Code buttons, Draft PR → Preview, no production merges.
2. **VR Fundamentals (blue)** — logic puzzles; SculptrVR sculpt; Rube Goldberg chain.
3. **Game Engine Basics (grey)** — import model; trigger action.
4. **Bedrock Add-on (gold)** — behavior/resource packs; items + entities JSON; Blockbench export.
5. **Java Mod (black)** — JDK+IDE; register item/entity; use-action spawns projectile.

See `paths.json` for module ordering, colors, and links.

## Bill Cipher (quip.js)
- **Enable:** `BillQuip.init()` (auto-idle quips ~45s).
- **Disable:** append `?quip=0` to URL.
- **Event hooks:** `BillQuip.on('previewReady' | 'questComplete' | 'error')`.
- **Custom lines:** add `public/data/bill_quips.json` (array of strings).

## UI Notes
- Cards use the palette: **blue** `#1f9cf0`, **grey** `#2a2f36`, **gold** `#d4af37`, **black** `#0a0c10`.
- Prefer Inter/Orbitron fonts; rounded cards; subtle shadows; high contrast text.

## Workflow
- Work on `feature/*` branches → **Draft PR → main** for **Cloudflare Preview**.
- `release` branch stays blocked (CI + branch protection).
- Use PR template checklist (rebuild data, attach preview, screenshots).

## Next Milestones
- **Quest detail page** `public/quest.html?id=...` with steps + localStorage progress.
- **Module filter** (Setup / VR / Engine / Bedrock / Java) on `quests.html`.
- **XP bar** that sums completed quests.
