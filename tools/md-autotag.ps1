<#
md-autotag.ps1
Auto-tags unlabeled fenced code blocks (``` ... ```) with likely language names
and ensures blank lines before/after fences (fixes MD031 + MD040).
#>

param([switch]$Apply)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Resolve-Path "$root\..")

# ---------- helper ----------
function Detect-Lang([string]$block) {
    $s = $block.Trim()
    if ($s -match '^\s*(flowchart|graph\s+(TD|LR)|sequenceDiagram|classDiagram)') { return 'mermaid' }
    elseif ($s -match '^\s*[\{\[]' -and $s -match '":\s*' -and $s -notmatch '<\w+') { return 'json' }
    elseif ($s -match '^\s*<(!DOCTYPE|html|div|span|script|link|meta|img|a|ul|ol|li|head|body)\b') { return 'html' }
    elseif ($s -match '(^|\r?\n)\s*\$[A-Za-z_]' `
        -or $s -match '\b(Get-ChildItem|Set-Content|Select-Object|Where-Object|Out-Null|Write-Host|Join-Path|Split-Path|Param)\b' `
        -or $s -match '\.ps1\b' `
        -or $s -match '^\s*PS\s*[>\)]') { return 'powershell' }
    elseif ($s -match '(^|\r?\n)\s*(git|npm|npx|ls|cd|mkdir|rm|mv|cp|curl|wget|tar|zip|unzip|export|bash|sh)\b') { return 'bash' }
    elseif ($s -match '(^|\r?\n)\s*(const|let|function|import\s+.*from\s+|export\s+)\b') { return 'js' }
    else { return 'bash' }
}

function Fix-BlankLines([string]$text) {
    # Blank line before fence
    $text = [regex]::Replace(
        $text,
        '([^\r\n])\r?\n```([A-Za-z]*)',
        { param($m) ($m.Groups[1].Value + "`r`n`r`n" + '```' + $m.Groups[2].Value) })
    # Blank line after fence
    $text = [regex]::Replace(
        $text,
        '```\s*(\r?\n)([^\r\n])',
        { param($m) ('```' + $m.Groups[1].Value + "`r`n" + $m.Groups[2].Value) })
    return $text
}

# ---------- scan ----------
$files = Get-ChildItem -Recurse -File -Include *.md |
    Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\.git\\' -and $_.FullName -notmatch '\\.github\\' }

$report = @()

foreach ($f in $files) {
    $raw = Get-Content $f.FullName -Raw
    $original = $raw

    # Add language tags
    $raw = [regex]::Replace(
        $raw,
        '```(\s*)(\r?\n)(.*?)(\r?\n)```',
        { param($m)
            $code = $m.Groups[3].Value
            $lang = Detect-Lang $code
            return ('```' + $lang + $m.Groups[2].Value + $code + $m.Groups[4].Value + '```')
        },
        [System.Text.RegularExpressions.RegexOptions]::Singleline)

    # Fix blank lines
    $raw = Fix-BlankLines $raw

    if ($raw -ne $original) {
        $report += [pscustomobject]@{ File = $f.FullName; Changed = $true }
        if ($Apply) { Set-Content -Path $f.FullName -Value $raw -NoNewline }
    }
    else {
        $report += [pscustomobject]@{ File = $f.FullName; Changed = $false }
    }
}

# ---------- summary ----------
$changed   = $report | Where-Object Changed
$unchanged = $report | Where-Object { -not $_.Changed }

Write-Host ""
Write-Host ("Files changed: {0}" -f $changed.Count)
$changed | ForEach-Object { Write-Host ("  • {0}" -f $_.File) }
Write-Host ("Files untouched: {0}" -f $unchanged.Count)

if (-not $Apply) {
    Write-Host "`n(Dry run) Re-run with -Apply to write changes."
} else {
    Write-Host "`n✅ Tags added and blank lines fixed. Ready to commit:"
    Write-Host '   git add **/*.md'
    Write-Host '   git commit -m "chore(docs): auto-tag fenced code blocks (MD040) + blank lines (MD031)"'
    Write-Host '   git push'
}
