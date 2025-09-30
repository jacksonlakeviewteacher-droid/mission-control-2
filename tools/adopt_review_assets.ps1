<#  adopt_review_assets.ps1
    Scoop media from staging (Google Drive "review") and repo, normalize names,
    dedupe by hash, classify, and build JSON manifests for images & sounds.
#>

[CmdletBinding()]
param(
  [string]$RepoRoot = 'C:\dev\mission-control-2',
  [string[]]$SourcePaths = @(
    'G:\My Drive\Mission-Control-2\review'  # staging
    # add more review subfolders here if you like
  ),
  [switch]$AlsoScanRepoPublic   # include existing stray media under /public
)

# ---- helpers ---------------------------------------------------------------
function Slug($s) {
  $s = [IO.Path]::GetFileNameWithoutExtension($s)
  $s = $s -replace '[^A-Za-z0-9\-_. ]','' -replace '\s+','-'
  $s = $s.Trim('-').ToLower()
  if (!$s) { $s = 'asset' }
  return $s
}
function SafeCopy($src, $dstFolder, $baseName) {
  $ext = [IO.Path]::GetExtension($src).ToLower()
  $name = "$baseName$ext"
  $dst  = Join-Path $dstFolder $name
  $i = 1
  while (Test-Path $dst) {
    $name = "{0}-{1}{2}" -f $baseName,$i,$ext
    $dst  = Join-Path $dstFolder $name
    $i++
  }
  Copy-Item $src $dst
  return $dst
}
function JsonSave($obj, $path) {
  $json = $obj | ConvertTo-Json -Depth 8
  $json | Set-Content -Path $path -Encoding UTF8
}

# ---- paths -----------------------------------------------------------------
$AssetsRoot   = Join-Path $RepoRoot 'public\assets'
$Inbox        = Join-Path $AssetsRoot '_inbox'
$ManiFolder   = Join-Path $AssetsRoot '_manifest'
$Targets = @{
  'concept\bill'        = 'bill|cipher|dorito'
  'concept\sharks'      = 'shark|megalodon|toxic|bone|octo|six-?head'
  'ui\icons\bc'         = 'icon|eye|symbol|sigil'
  'backgrounds'         = 'bg|background|wallpaper|space|sky|stars|cloud|zodiac|lava|island|lab'
  'illustrations'       = 'illustration|poster|meme|art'
  'overlays'            = 'overlay|frame|border|glitch'
  'tiles'               = 'tile|tileset|sprites?heet'
}
$ImgExt = '.png','.jpg','.jpeg','.gif','.webp','.bmp'
$AudExt = '.mp3','.wav','.ogg','.oga','.m4a'

# ---- collect candidates ----------------------------------------------------
$candidates = @()

foreach ($p in $SourcePaths) {
  if (Test-Path $p) {
    $candidates += Get-ChildItem -LiteralPath $p -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $ImgExt -contains $_.Extension.ToLower() -or $AudExt -contains $_.Extension.ToLower() }
  }
}

if ($AlsoScanRepoPublic) {
  $pub = Join-Path $RepoRoot 'public'
  if (Test-Path $pub) {
    $candidates += Get-ChildItem -LiteralPath $pub -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $ImgExt -contains $_.Extension.ToLower() -or $AudExt -contains $_.Extension.ToLower() }
  }
}

$candidates = $candidates | Sort-Object -Property FullName -Unique

# ---- de-dupe by SHA-1 and copy into _inbox --------------------------------
$seen = @{}
$adopted = @()
$candidates | ForEach-Object {
  try {
    $h = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA1).Hash
    if ($seen.ContainsKey($h)) { return }
    $seen[$h] = $true
    $base = Slug($_.Name)
    $copied = SafeCopy -src $_.FullName -dstFolder $Inbox -baseName $base
    $adopted += $copied
  } catch {
    Write-Warning "Hash/copy failed: $($_.FullName)  $_"
  }
}

Write-Host "Adopted $($adopted.Count) files into $Inbox"

# ---- classify out of _inbox ------------------------------------------------
$classified = @()
foreach ($file in Get-ChildItem $Inbox -File) {
  $name = $file.Name.ToLower()
  $destRel = $null
  foreach ($kv in $Targets.GetEnumerator()) {
    if ($name -match $kv.Value) { $destRel = $kv.Key; break }
  }
  if (-not $destRel) {
    # images default to illustrations, audio to sounds\sfx
    if ($ImgExt -contains $file.Extension.ToLower()) { $destRel = 'illustrations' }
    else { $destRel = 'sounds\sfx' }
  }
  $destFolder = Join-Path $AssetsRoot $destRel
  New-Item -ItemType Directory -Force -Path $destFolder | Out-Null
  $base = Slug($file.Name)
  $moved = SafeCopy -src $file.FullName -dstFolder $destFolder -baseName $base
  Remove-Item $file.FullName -Force
  $classified += $moved
}

Write-Host "Classified $($classified.Count) files."

# ---- manifests -------------------------------------------------------------
Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue | Out-Null
$images = @(); $sounds = @()

Get-ChildItem $AssetsRoot -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($AssetsRoot.Length+1) -replace '\\','/'
  $ext = $_.Extension.ToLower()
  if ($ImgExt -contains $ext) {
    $w=$null;$h=$null
    try {
      $img = [System.Drawing.Image]::FromFile($_.FullName)
      $w=$img.Width; $h=$img.Height
      $img.Dispose()
    } catch { }
    $images += [pscustomobject]@{
      name     = [IO.Path]::GetFileNameWithoutExtension($_.Name)
      path     = "assets/$rel"
      width    = $w
      height   = $h
      tags     = @()  # fill later if you want
    }
  } elseif ($AudExt -contains $ext) {
    $sounds += [pscustomobject]@{
      name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
      path = "assets/$rel"
      tags = @()
    }
  }
}

JsonSave $images "$ManiFolder\images.json"
JsonSave $sounds "$ManiFolder\sounds.json"

Write-Host "Wrote manifests:"
Write-Host "  $ManiFolder\images.json  ($($images.Count) items)"
Write-Host "  $ManiFolder\sounds.json  ($($sounds.Count) items)"
