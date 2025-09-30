# Builds assets/manifest.json (from assets/ + public/*) and seeds assets/pages.json if missing
$ErrorActionPreference = 'Stop'
$root = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { (Get-Location).Path }
$assetsDir = Join-Path $root 'assets'
New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null

$manifestPath = Join-Path $assetsDir 'manifest.json'
$pagesPath    = Join-Path $assetsDir 'pages.json'
$imgExt = @('.png','.jpg','.jpeg','.gif','.webp','.svg')
$audExt = @('.mp3','.wav','.ogg')

$scan = @(
  Join-Path $root 'assets',
  Join-Path $root 'public\sprites',
  Join-Path $root 'public\overlays',
  Join-Path $root 'public\wallpapers',
  Join-Path $root 'public\sounds',
  Join-Path $root 'public\icons'
) | Where-Object { Test-Path $_ }

$items = foreach($base in $scan){
  Get-ChildItem -Path $base -Recurse -File -Force | ForEach-Object {
    $ext = $_.Extension.ToLower()
    if ($imgExt -notcontains $ext -and $audExt -notcontains $ext) { return }
    $rel = $_.FullName.Substring($root.Length+1).Replace('\','/')
    $kind = if ($imgExt -contains $ext) { 'image' } else { 'audio' }
    $tags = ((Split-Path $rel -Parent) -split '/') + @($_.BaseName)
    [pscustomobject]@{
      id   = ($_.BaseName -replace '[^a-zA-Z0-9_]+','_').ToLower()
      path = $rel
      kind = $kind
      ext  = $ext.TrimStart('.')
      tags = $tags | Where-Object { $_ }
    }
  }
}
($items | Sort-Object path | ConvertTo-Json -Depth 6) | Set-Content -Path $manifestPath -Encoding utf8

if (-not (Test-Path $pagesPath)) {
  @{ pages=@(); sounds=@() } | ConvertTo-Json -Depth 8 | Set-Content -Path $pagesPath -Encoding utf8
}
Write-Host "Manifest: $manifestPath"
Write-Host "Pages:    $pagesPath (created if missing)"
