param(
  [string]$ToolsDir = $PSScriptRoot,
  [switch]$WhatIf
)

# Header (auto-hop to pwsh + dot-source common helpers)
$header = @"
#region pwsh-shim
if (\$PSVersionTable.PSVersion.Major -lt 7) {
  \$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
  if (\$pwsh) {
    & \$pwsh.Path -File \$PSCommandPath @args
    exit \$LASTEXITCODE
  }
}
#endregion
. `"\$PSScriptRoot\mc.common.ps1`"

"@

$targets = Get-ChildItem -LiteralPath $ToolsDir -Filter *.ps1 |
           Where-Object { $_.Name -notin @('install_pwsh_shim.ps1','mc.common.ps1') }

foreach ($f in $targets) {
  $text = Get-Content -LiteralPath $f.FullName -Raw

  # 1) Ensure header present (idempotent)
  if ($text -notmatch 'pwsh-shim') {
    Write-Host "Prepending pwsh shim to $($f.Name)..."
    if (-not $WhatIf) { Set-Content -LiteralPath $f.FullName -Value ($header + $text) -Encoding UTF8 }
    $text = $header + $text
  }
  # 2) Ensure the dot-source line exists (in case a very old header lacked it)
  if ($text -notmatch [regex]::Escape('. "$PSScriptRoot\mc.common.ps1"')) {
    Write-Host "Adding . mc.common.ps1 to $($f.Name)..."
    if (-not $WhatIf) { Set-Content -LiteralPath $f.FullName -Value ($header + $text) -Encoding UTF8 }
  }

  # 3) Rewrite common JSON reads to the helpers (PS7: -AsHashtable; PS5.1: fallback)
  $text2 = [regex]::Replace(
    $text,
    'Get-Content\s+(\$[\w:]+)\s+-Raw\s*\|\s*ConvertFrom-Json(?:\s+-Depth\s+\d+)?',
    'Read-Json -Path $1',
    'IgnoreCase'
  )
  $text2 = [regex]::Replace(
    $text2,
    '(?<!\|.*?)\bConvertFrom-Json\s+(\$[\w:]+)',
    'Read-JsonText $1',
    'IgnoreCase'
  )
  if ($text2 -ne $text) {
    Write-Host "Rewriting JSON reads in $($f.Name)..."
    if (-not $WhatIf) { Set-Content -LiteralPath $f.FullName -Value $text2 -Encoding UTF8 }
  }
}
Write-Host "Done. Scripts now auto-prefer pwsh and use -AsHashtable on PS7+."
