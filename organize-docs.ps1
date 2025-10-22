<#
Script: organize-docs.ps1
Purpose: Standardize documentation and GitHub helper layout for Mission Control / Shark Gun v25
#>

Write-Host "=== Organizing documentation files for Mission Control ===`n"

# Create folders if they don’t exist
$docsPath = "docs"
$githubPath = ".github"

if (!(Test-Path $docsPath)) {
    Write-Host "Creating docs folder..."
    New-Item -ItemType Directory -Path $docsPath | Out-Null
}

if (!(Test-Path $githubPath)) {
    Write-Host "Creating .github folder..."
    New-Item -ItemType Directory -Path $githubPath | Out-Null
}

# Move & rename core docs (if they exist)
$moveList = @{
    "dev.md"                = "$docsPath\DEV_GUIDE.md"
    "Flow (1).md"           = "$docsPath\FLOW.md"
    "contributing mdt.md"   = "CONTRIBUTING.md"
    "Hand-off vs 25.md"     = "HANDOFF_v25.md"
    "pull request template.md" = "$githubPath\pull_request_template.md"
}

foreach ($src in $moveList.Keys) {
    if (Test-Path $src) {
        $dest = $moveList[$src]
        Write-Host "Moving $src → $dest"
        Move-Item -LiteralPath $src -Destination $dest -Force
    } else {
        Write-Host "Skipping $src (not found)"
    }
}

# Stage and commit changes
Write-Host "`nStaging and committing..."
git add -A
git commit -m "chore(docs): organize DEV_GUIDE, FLOW, CONTRIBUTING, HANDOFF_v25 + PR template" 2>$null
git push

Write-Host "`n✅ Documentation structure updated and pushed!"
Write-Host "Docs → /docs, CONTRIBUTING → root, PR template → .github/"
