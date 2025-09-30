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

# ----- paths
$Public = Join-Path $Root "public"
$Icons  = Join-Path $Public "sprites\icons"
$Walls  = Join-Path $Public "wallpapers"
$SfxDir = Join-Path $Public "sounds\sfx"
ni $Icons,$Walls,$SfxDir -ItemType Directory -Force | Out-Null

# ----- planned moves/renames (relative to /public)
$plan = @(
  @{ find='icon_bc_bedrock_vs_java.jpg';    to='sprites\icons\bc_icon_versions.jpg'     }
  @{ find='icon_bc_java.jpg';               to='sprites\icons\bc_icon_java.jpg'         }
  @{ find='icon_bc_notebook.jpg';           to='sprites\icons\bc_icon_notes.jpg'        }
  @{ find='icon_bc_frown_notebook.jpg';     to='sprites\icons\bc_icon_issues.jpg'       }
  @{ find='icon_bc_sounds.png';             to='sprites\icons\bc_icon_sounds.png'       }
  @{ find='icon_bc_sounds_transparent.png'; to='sprites\icons\bc_icon_sounds_alt.png'   }
  @{ find='bc_round_pixelated.png';         to='sprites\icons\bc_icon_retro_pixel.png'  }
  @{ find='bc_round_runtime_error.png';     to='wallpapers\bg_runtime_error.png'        }
  @{ find='sfx_glitch.mp3';                 to='sounds\sfx\sfx_glitch.mp3'              }
  @{ find='sfx_coin.wav';                   to='sounds\sfx\sfx_coin.wav'                 }
)

# ----- move/rename on G:
foreach($it in $plan){
  $hit = Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue |
         Where-Object { $_.Name -ieq $it.find } | Select-Object -First 1
  if(-not $hit){ Write-Warning "Not found: $($it.find)"; continue }
  $dest = Join-Path $Public $it.to
  ni (Split-Path $dest) -ItemType Directory -Force | Out-Null
  if($Preview){ "[Preview] Move: $($hit.FullName) -> $dest" }
  else{
    Move-Item -LiteralPath $hit.FullName -Destination $dest -Force
    Write-Host "Moved: $($hit.Name) -> $($it.to)"
  }
}

# ----- mirror to C:\Dev and rebuild indexes
if($Preview){ "[Preview] Mirror public -> C:\Dev\public" }
else{
  robocopy "$Public" "$DevRoot\public" *.* /E /MIR | Out-Null
  & py -3 "$DevRoot\tools\build_asset_index.py"
  if(Test-Path "$DevRoot\tools\build_sounds_index.py"){ & py -3 "$DevRoot\tools\build_sounds_index.py" }
}

# ----- mapping updates (paths_assets.json)
function JsonToHashtable($obj){
  if($null -eq $obj){return $null}
  if($obj -is [pscustomobject]){
    $ht=@{}; foreach($p in $obj.PSObject.Properties){ $ht[$p.Name]=JsonToHashtable $p.Value }; return $ht
  } elseif($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string])){
    return @($obj | ForEach-Object { JsonToHashtable $_ })
  } else { return $obj }
}
function URL($underDevPublic){
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
  icon_versions = URL "$DevRoot\public\sprites\icons\bc_icon_versions.jpg"
  icon_java     = URL "$DevRoot\public\sprites\icons\bc_icon_java.jpg"
  icon_notes    = URL "$DevRoot\public\sprites\icons\bc_icon_notes.jpg"
  icon_issues   = URL "$DevRoot\public\sprites\icons\bc_icon_issues.jpg"
  icon_sounds   = URL "$DevRoot\public\sprites\icons\bc_icon_sounds.png"
  icon_retro    = URL "$DevRoot\public\sprites\icons\bc_icon_retro_pixel.png"
  wall_error    = URL "$DevRoot\public\wallpapers\bg_runtime_error.png"
  sfx_glitch    = URL "$DevRoot\public\sounds\sfx\sfx_glitch.mp3"
  sfx_coin      = URL "$DevRoot\public\sounds\sfx\sfx_coin.wav"
}

# add/refresh suggested tiles (non-destructive: only sets provided fields)
SetCfg $map 'versions' @{ icon=$U.icon_versions }
SetCfg $map 'java'     @{ icon=$U.icon_java }
SetCfg $map 'notes'    @{ icon=$U.icon_notes }
SetCfg $map 'issues'   @{ icon=$U.icon_issues; sfx=$U.sfx_glitch }
SetCfg $map 'sounds'   @{ icon=$U.icon_sounds; sfx=$U.sfx_coin }
SetCfg $map 'retro'    @{ icon=$U.icon_retro }
SetCfg $map 'errors'   @{ wallpaper=$U.wall_error; sfx=$U.sfx_glitch }
# wire coin sound to treasures too (if you use that tile)
SetCfg $map 'treasures' @{ sfx=$U.sfx_coin }

if($Preview){
  "[Preview] Would write: $mapPath"
  $map | ConvertTo-Json -Depth 100
}else{
  ni (Split-Path $mapPath) -ItemType Directory -Force | Out-Null
  $map | ConvertTo-Json -Depth 100 | Set-Content $mapPath -Encoding UTF8
  "Updated $mapPath"
}


