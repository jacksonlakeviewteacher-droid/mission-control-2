<#
Script: fix-markdownlint.ps1
Purpose: Automatically fix common markdownlint warnings (MD031 + MD040)
Applies to: all .md files in repo
#>

Write-Host "=== Fixing markdownlint formatting in Markdown files ===`n"

# Define folder paths
$repoRoot = Get-Location
$docsFolders = @("$repoRoot", "$repoRoot\docs")

# Define regex patterns
$noLangPattern = '```(\r?\n|$)'              # Fences with no language tag
$noBlankBeforePattern = '([^\r\n])\r?\n```'  # Missing blank line before code block
$noBlankAfterPattern = '```\r?\n([^\r\n])'   # Missing blank line after code block

# Find all markdown files
$files = Get-ChildItem -Path $docsFolders -Recurse -Include *.md -File

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $original = $content

    # Ensure blank line before and after fenced code blocks
    $content = $content -replace $noBlankBeforePattern, '$1`r`n`r`n```'
    $content = $content -replace $noBlankAfterPattern, '```' + "`r`n`r`n" + '$1'

    # Auto-tag common code blocks if they’re missing a language
    # (PowerShell, Bash, JSON, Mermaid are most common in your docs)
    $content = $content -replace '```powershell', '```powershell'
    $content = $content -replace '```bash', '```bash'
    $content = $content -replace $noLangPattern, '```bash`r`n'   # Default to bash if unknown

    if ($content -ne $original) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "✅ Fixed: $($file.Name)"
    } else {
        Write-Host "— No changes: $($file.Name)"
    }
}

Write-Host "`nAll Markdown files processed. Ready to commit.`n"
