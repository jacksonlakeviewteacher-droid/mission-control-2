# Flow — Feature → main → release (Cloudflare)

**Cloudflare Production branch:** `release`  
**Default branch on GitHub:** `main`

> Daily:
> 1) `git checkout feature-<name>`
> 2) `git pull --rebase`
> 3) edit → `git add -A && git commit -m "..." && git push`
> 4) Open PR to `main` for Preview
> 5) When ready: PR `main → release` to publish

```mermaid

flowchart LR
  subgraph Dev["Feature Branch (PR → main)"]
    A[Local edits] --> B[git add/commit/push]
  end

  B --> C[GitHub PR: feature → main]
  C --> D{Cloudflare Preview Build}
  D -->|green| E[Preview URL shared/tested]
  C --> F[Merge to main]

  F --> G[PR: main → release]
  G --> H{Cloudflare Production Build}
  H -->|green| I[Live on PRODUCTION]
