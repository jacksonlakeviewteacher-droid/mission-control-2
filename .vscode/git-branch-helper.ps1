# .vscode/git-branch-helper.ps1
# Create a safe feature branch from main, push it, and open a PR page.

$ErrorActionPreference = "Stop"

# .vscode/git-branch-helper.ps1
# Create a safe feature branch from main, push it, and open a PR page.

$ErrorActionPreference = "Stop"

function Git([string[]]$gitArgs) {
  $p = Start-Process -FilePath "git" -ArgumentList $gitArgs -NoNewWindow -PassThru -Wait
  if ($p.ExitCode -ne 0) { throw "git $gitArgs failed with exit code $($p.ExitCode)" }
}

# Ensure we're inside a git repo and move to repo root
$repo = (git rev-parse --show-toplevel 2>$null)
if (-not $repo) { throw "Not inside a Git repository." }
Set-Location $repo

# Fetch & update main safely
Git @("fetch","--all","--prune")
Git @("checkout","main")
Git @("pull","--rebase","--autostash")

# Ask for a short branch label and make a clean slug
$raw = Read-Host "Short name for your branch (e.g. rebuild-data, questline-flow, ui-refresh)"
if ([string]::IsNullOrWhiteSpace($raw)) { $raw = "wip" }
$slug = $raw.ToLower().Trim() -replace "[^a-z0-9\-]+","-" -replace "^-+","" -replace "-+$",""
$stamp = Get-Date -Format "yyyyMMdd-HHmm"
$branch = "feature/$slug-$stamp"

# Create the branch and push upstream
Git @("checkout","-b",$branch)
Git @("push","-u","origin",$branch)

Write-Host ""
Write-Host "✅ Created & pushed $branch" -ForegroundColor Green
Write-Host ""

# Build a PR URL for GitHub and open it
$remote = (git remote get-url origin).Trim()

# Normalize the origin URL to https://github.com/owner/repo
if ($remote -match "^git@github\.com:(.+)\.git$") {
  $path = $Matches[1]
  $https = "https://github.com/$path"
} elseif ($remote -match "^https://github\.com/(.+)\.git$") {
  $https = "https://github.com/$($Matches[1])"
} else {
  $https = $remote
}

# Open the Compare PR page: base = main, compare = new branch
$prUrl = "$https/compare/main...$branch?expand=1"
Write-Host "🔗 PR: $prUrl"
try { Start-Process $prUrl } catch { Write-Host "Open this URL in your browser:"; Write-Host $prUrl }

Write-Host ""
Write-Host "🌈 Cloudflare Pages will auto-create a Preview deployment for this branch." -ForegroundColor Cyan
Write-Host "   Nothing touches production until you merge to release." -ForegroundColor Yellow
