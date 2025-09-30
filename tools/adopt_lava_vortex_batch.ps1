#region pwsh-shim
if (\System.Collections.Hashtable.PSVersion.Major -lt 7) {
  \ = Get-Command pwsh -ErrorAction SilentlyContinue
  if (\) {
    & \.Path -File \G:\My Drive\Mission-Control-2\tools\install_pwsh_shim.ps1 @args
    exit \0
  }
}
#endregion
. "\G:\My Drive\Mission-Control-2\tools\mc.common.ps1"
#region pwsh-shim
if (\System.Management.Automation.PSVersionHashTable.PSVersion.Major -lt 7) {
  \ = Get-Command pwsh -ErrorAction SilentlyContinue
  if (\) {
    & \.Path -File \G:\My Drive\Mission-Control-2\tools\install_pwsh_shim.ps1 @args
    exit \
  }
}
#endregion
. "\G:\My Drive\Mission-Control-2\tools\mc.common.ps1"
param(
  [string]$Root    = "G:\My Drive\Mission-Control-2",
  [string]$DevRoot = "C:\Dev\Mission-Control-2",
  [switch]$Preview
)

$Public = Join-Path $Root "public"
$Icons  = Join-Path $Public "sprites\icons"
$Sharks = Join-Path $Public "sprites\sharks"
$Walls  = Join-Path $Public "wallpapers"
$Over   = Join-Path $Public "overlays"

ni $Icons,$Sharks,$Walls,$Over -ItemType Directory -Force | Out-Null

function Move-Norm([string]$find,[string]$toRel){
  $hit = Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue |
         Where-Object { $_.Name -ieq $find } | Select-Object -First 1
  if(-not $hit){ Write-Warning "Not found: $find"; return $null }
  $dest = Join-Path $Public $toRel
  ni (Split-Path $dest) -ItemType Directory -Force | Out-Null
  if($Preview){ "[Preview] Move: $($hit.FullName) -> $dest" }
  else{ Move-Item -LiteralPath $hit.FullName -Destination $dest -Force; "Moved: $find -> $toRel" }
}

# -------- place/rename this batch
$placed = @{}
$placed['wall_living']   = Move-Norm 'bc_living_room.JPG'             'wallpapers\bg_living_room.jpg'
$placed['icon_sharkgun'] = Move-Norm 'catfish_gun.PNG'                 'sprites\sharks\sharkgun_catfish.png'
$placed['icon_blocks']   = Move-Norm 'cipher_os_block.PNG'             'sprites\icons\bc_icon_blocks.png'
$placed['wall_cubes']    = Move-Norm 'cube_lava_rocks_falling.JPG'     'wallpapers\bg_lava_cubes.jpg'
$placed['wall_diamonds'] = Move-Norm 'diamond_blocks.PNG'              'wallpapers\bg_diamond_blocks.png'
$placed['ov_vortex']     = Move-Norm 'electric_vortex.PNG'             'overlays\overlay_electric_vortex.png'
$placed['wall_volcano']  = Move-Norm 'floating_volcano.JPG'            'wallpapers\bg_floating_volcano.jpg'
$placed['wall_islands']  = Move-Norm 'multiple_floating_lava_islands.JPG' 'wallpapers\bg_lava_islands.jpg'
$placed['icon_boss']     = Move-Norm 'round_beat_up_sharks_in_globe.PNG' 'sprites\icons\bc_icon_boss.png'
$placed['icon_sharkdex'] = Move-Norm 'sharks_of_the_world.JPG'         'sprites\icons\bc_icon_sharkdex.jpg'

# -------- mirror to C:\Dev and rebuild indices
if($Preview){ "[Preview] Mirror public -> $DevRoot\public" }
else{
  robocopy "$Public" "$DevRoot\public" *.* /E /MIR | Out-Null
  if(Test-Path "$DevRoot\tools\build_asset_index.py"){ & py -3 "$DevRoot\tools\build_asset_index.py" }
  if(Test-Path "$DevRoot\tools\build_sounds_index.py"){ & py -3 "$DevRoot\tools\build_sounds_index.py" }
}

# -------- update paths_assets.json (non-destructive)
function JsonToHashtable($obj){
  if($null -eq $obj){return $null}
  if($obj -is [pscustomobject]){
    $h=@{}; foreach($p in $obj.PSObject.Properties){ $h[$p.Name]=JsonToHashtable $p.Value }; return $h
  } elseif($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string])){
    return @($obj | ForEach-Object { JsonToHashtable $_ })
  } else { return $obj }
}
function URL($underDevPublic,[string]$DevRoot){
  if(Test-Path $underDevPublic){ return "/" + ($underDevPublic -replace [regex]::Escape("$DevRoot\public\"), "" -replace "\\","/") }
  return $null
}
function SetCfg([hashtable]$map,[string]$key,[hashtable]$kv){
  if(-not $map.paths.ContainsKey($key)){ $map.paths[$key]=@{} }
  foreach($k in $kv.Keys){ if($kv[$k]){ $map.paths[$key][$k]=$kv[$k] } }
}

$mapPath = "$DevRoot\public\data\paths_assets.json"
$map = if(Test-Path $mapPath){ JsonToHashtable (Read-Json -Path $mapPath) } else { @{ paths=@{}; overlays=@{} } }
if(-not $map.ContainsKey('paths')){ $map['paths']=@{} }
if(-not $map.ContainsKey('overlays')){ $map['overlays']=@{} }

$U = @{
  living   = URL "$DevRoot\public\wallpapers\bg_living_room.jpg" $DevRoot
  cubes    = URL "$DevRoot\public\wallpapers\bg_lava_cubes.jpg" $DevRoot
  diamonds = URL "$DevRoot\public\wallpapers\bg_diamond_blocks.png" $DevRoot
  volcano  = URL "$DevRoot\public\wallpapers\bg_floating_volcano.jpg" $DevRoot
  islands  = URL "$DevRoot\public\wallpapers\bg_lava_islands.jpg" $DevRoot
  boss     = URL "$DevRoot\public\sprites\icons\bc_icon_boss.png" $DevRoot
  blocks   = URL "$DevRoot\public\sprites\icons\bc_icon_blocks.png" $DevRoot
  sharkgun = URL "$DevRoot\public\sprites\sharks\sharkgun_catfish.png" $DevRoot
  sharkdex = URL "$DevRoot\public\sprites\icons\bc_icon_sharkdex.jpg" $DevRoot
  ov_vortex= URL "$DevRoot\public\overlays\overlay_electric_vortex.png" $DevRoot

  sfx_expl = URL "$DevRoot\public\sounds\sfx\sfx_very_big_explosion.mp3" $DevRoot
  sfx_coin = URL "$DevRoot\public\sounds\sfx\sfx_coin.wav" $DevRoot
  sfx_zap  = URL "$DevRoot\public\sounds\sfx\sfx_glitch.mp3" $DevRoot
}

# tiles / pages
SetCfg $map 'livingroom' @{ wallpaper=$U.living;  icon=$U.blocks }   # placeholder icon
SetCfg $map 'lava'       @{ wallpaper=$U.cubes;   sfx=$U.sfx_zap }
SetCfg $map 'diamonds'   @{ wallpaper=$U.diamonds }
SetCfg $map 'volcano'    @{ wallpaper=$U.volcano; sfx=$U.sfx_expl }
SetCfg $map 'islands'    @{ wallpaper=$U.islands; sfx=$U.sfx_expl }

SetCfg $map 'boss'       @{ icon=$U.boss;    sfx=$U.sfx_expl }
SetCfg $map 'blocks'     @{ icon=$U.blocks }
SetCfg $map 'sharkgun'   @{ icon=$U.sharkgun }
SetCfg $map 'sharkdex'   @{ icon=$U.sharkdex; sfx=$U.sfx_coin }

# overlay
if($U.ov_vortex){ $map.overlays['electric_vortex'] = $U.ov_vortex }

if($Preview){
  "[Preview] Would write $mapPath"
  $map | ConvertTo-Json -Depth 100
}else{
  ni (Split-Path $mapPath) -ItemType Directory -Force | Out-Null
  $map | ConvertTo-Json -Depth 100 | Set-Content $mapPath -Encoding UTF8
  "Updated $mapPath"
}


