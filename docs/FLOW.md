# Flow — Feature → main → release (Cloudflare)

**Cloudflare Production branch:** `release`
**Default branch on GitHub:** `main``r`n`r`n```bash`r`n[feature-xyz] --PR--> [main] --PR--> [release] --> Cloudflare PRODUCTION
       |                ^
       |__ Preview URL _|   (Cloudflare builds previews for PRs)`r`n`r`n```bash`r`n
**Daily:**

1) `git checkout feature-<name>`
2) `git pull --rebase`
3) edit → `git add -A && git commit -m "..." && git push`
4) Open PR to `main` for Preview
5) When ready: PR `main → release` to publish
