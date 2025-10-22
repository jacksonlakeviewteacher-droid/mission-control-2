# Pull Request Template

## 🧾 What Changed

- Brief summary of what this PR does
- Link any related issues or tasks

## 🧪 How to Test

1. Steps to reproduce or verify changes
2. Note any special test cases

## 🌐 Cloudflare Preview

- (CI will comment the URL. If not:)
  Paste Pages preview URL here → `https://<your-project>--<branch>.pages.dev/`

---

## ✅ Checklist

### Branch & Safety

- [ ] PR targets `feature/*` (not `main`)
- [ ] Pulled latest base branch and resolved conflicts
- [ ] Commits are small and focused

### Build & Data

- [ ] Rebuilt data (`Ctrl+Alt+R` or `Ctrl+Alt+D`)
- [ ] Verified regenerated JSONs in `public/data/`:
  - `asset_index.json`
  - `tools_meta.json`
  - `quests_meta.json`

### Preview

- [ ] Cloudflare Pages **Preview build is green**
- [ ] Preview URL tested (key pages load: `index.html`, `quests.html`, etc.)

### Content

- [ ] No broken images/icons in `public/assets/*`
- [ ] Internal links work (Home → Paths → Quests → Sidequests)

---

## 🧭 References

- [Developer Guide](../docs/DEV_GUIDE.md)
- [Flow Map](../docs/FLOW.md)
