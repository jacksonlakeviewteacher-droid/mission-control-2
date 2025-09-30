[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [Parameter(Mandatory)][string]$SourceRoot,  # e.g. "G:\My Drive\Mission-Control-2\_staging"
  [Parameter(Mandatory)][string]$DestRoot,    # e.g. "C:\dev\mission-control-2\public"
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
if (!(Test-Path -LiteralPath $SourceRoot)) { throw "SourceRoot not found: $SourceRoot" }
New-Item -ItemType Directory -Force -Path $DestRoot | Out-Null

function Slug([string]$s) {
  ($s -replace '\s+','_' -replace '[^a-zA-Z0-9_\.-]','' -replace '_+','_').Trim('_').ToLower()
}
function Get-TargetRelPath([string]$name, [string]$ext) {
  $n = $name.ToLower()
  if ($ext -match '^(mp3|wav|ogg)$') {
    if ($n -like 'bc_*') { return "sounds/bill/$name.$ext" }
    if ($n -like 'sfx_*') { return "sounds/sfx/$name.$ext" }
    return "sounds/other/$name.$ext"
  }
  if ($n -match 'icon|ui_|^icon_')           { return "sprites/icons/$name.$ext" }
  if ($n -match 'treasure|chest')            { return "sprites/treasures/$name.$ext" }
  if ($n -match 'overlay|glitch|vortex|fx')  { return "overlays/$name.$ext" }
  if ($n -match 'shark')                     { return "sprites/sharks/$name.$ext" }
  if ($n -match 'bill|bc_')                  { return "sprites/bill/$name.$ext" }
  if ($n -match 'wallpaper|background|bg_')  { return "wallpapers/$name.$ext" }
  if ($ext -eq 'gif') { return "overlays/$name.$ext" }
  return "sprites/misc/$name.$ext"
}

$imgExt = @('.png','.jpg','.jpeg','.gif','.webp','.svg')
$audExt = @('.mp3','.wav','.ogg')

Get-ChildItem -LiteralPath $SourceRoot -Recurse -File | ForEach-Object {
  $ext = $_.Extension.TrimStart('.').ToLower()
  if ($imgExt -notcontains ".$ext" -and $audExt -notcontains ".$ext") { return }
  $slug = Slug ([IO.Path]::GetFileNameWithoutExtension($_.Name))
  $targetRel = Get-TargetRelPath -name $slug -ext $ext
  $targetAbs = Join-Path $DestRoot $targetRel
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $targetAbs) | Out-Null
  if ($WhatIf) { Write-Host "[DRY RUN] -> $targetRel" }
  else { Copy-Item -LiteralPath $_.FullName -Destination $targetAbs -Force; Write-Host "Copied -> $targetRel" }
}
Write-Host "Done."
