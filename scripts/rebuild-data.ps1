<# =====================================================================
  rebuild-data.ps1
  Rebuilds:
    - public\data\asset_index.json
    - public\data\tools_meta.json
    - public\data\quests_meta.json

  Optional:
    -AutoCommit        -> git add/commit the three files
    -NoPush            -> commit only (skip push)
    -Message "text"    -> commit message

  Safe to run multiple times. Uses only local repo content.
===================================================================== #>

[CmdletBinding()]
param(
  [switch] $AutoCommit,
  [switch] $NoPush,
  [string] $Message = 'chore: rebuild data JSONs'
)

$ErrorActionPreference = 'Stop'

# --- Resolve repo root from this script location ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root      = Split-Path -Parent $ScriptDir

Set-Location $Root

# --- Paths ---
$AssetsDir = Join-Path $Root 'public\assets'
$DataDir   = Join-Path $Root 'public\data'
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

$AssetIndexPath = Join-Path $DataDir 'asset_index.json'
$ToolsMetaPath  = Join-Path $DataDir 'tools_meta.json'
$QuestsMetaPath = Join-Path $DataDir 'quests_meta.json'

# --- Helpers ---
function ConvertTo-RelWebPath([string]$Full) {
  return $Full.Replace("$Root\","").Replace("\","/")
}

function Find-Icon([string[]]$candidates, [string[]]$haystack) {
  foreach ($c in $candidates) {
    $hit = $haystack | Where-Object { $_ -match $c } | Select-Object -First 1
    if ($hit) { return $hit }
  }
  return $null
}

# --- Inventory assets on disk ---
$icons = @()
if (Test-Path "$AssetsDir\ui\icons") {
  $icons = Get-ChildItem "$AssetsDir\ui\icons" -Recurse -Include *.png,*.jpg,*.webp |
           ForEach-Object { ConvertTo-RelWebPath $_.FullName }
}

$backgrounds = @()
if (Test-Path "$AssetsDir\backgrounds") {
  $backgrounds = Get-ChildItem "$AssetsDir\backgrounds" -Recurse -Include *.jpg,*.png,*.webp |
                 ForEach-Object { ConvertTo-RelWebPath $_.FullName }
}

# --- Write asset_index.json ---
$assetIndex = [ordered]@{
  generated_at = (Get-Date).ToUniversalTime().ToString('u')
  icons        = $icons
  backgrounds  = $backgrounds
}
$assetIndex | ConvertTo-Json -Depth 6 | Set-Content -Path $AssetIndexPath -Encoding UTF8

# --- Phase colors (used by maps/UI) ---
$phaseColors = @{
  Portal    = '#e879f9'
  Setup     = '#60a5fa'
  Modeling  = '#22d3ee'
  Texturing = '#34d399'
  Sound     = '#facc15'
  Logic     = '#f97316'
  Testing   = '#fb7185'
  Export    = '#a78bfa'
}

# --- Build tools_meta.json ---
$phases = @(
  [ordered]@{
    id='Q0'; phase='Portal'; title='The Fork in the Code'; color=$phaseColors.Portal
    purpose='Choose Java vs Bedrock; orient.'
    core=@('Mission Control site','GitHub (Pages/PRs)')
    optional=@('VS Code (notes)','Python local server')
    icons=@( Find-Icon @('portal','versions','bc_icon_versions') $icons )
    quip='Two doors diverged in the void—pick the one with teeth.'
  },
  [ordered]@{
    id='Q1'; phase='Setup'; title='Mission Prep'; color=$phaseColors.Setup
    purpose='Folders, installs, first run.'
    core=@('Forge','MCreator','VS Code','Git / GitHub Desktop')
    optional=@('PowerShell / Git Bash','Python (http.server)')
    icons=@(
      Find-Icon @('forge','bc_icon_forge') $icons
      Find-Icon @('os-tools','bc_icon_os_tools') $icons
    ) | Where-Object { $_ }
    quip='Install now, explode later.'
  },
  [ordered]@{
    id='Q2'; phase='Modeling'; title='Prototype the Shark Gun'; color=$phaseColors.Modeling
    purpose='Design weapon model.'
    core=@('Blockbench')
    optional=@('Tinkercad','Blender')
    icons=@( Find-Icon @('sharkgun','blockbench','bc_icon_sharkgun') $icons ) | Where-Object { $_ }
    quip='Shape chaos into geometry.'
  },
  [ordered]@{
    id='Q3'; phase='Texturing'; title='Skin of the Shark'; color=$phaseColors.Texturing
    purpose='Create & map textures.'
    core=@('Paint.NET','Aseprite','Photopea')
    optional=@('Adobe Express / Firefly')
    icons=@( Find-Icon @('textur','art-suite','paintnet','aseprite') $icons ) | Where-Object { $_ }
    quip='Pixels crave meaning—feed them.'
  },
  [ordered]@{
    id='Q4'; phase='Sound'; title='Echoes of the Deep'; color=$phaseColors.Sound
    purpose='Design/import SFX.'
    core=@('Audacity','Bfxr')
    optional=@('Tone generators','AI voices (optional)')
    icons=@( Find-Icon @('audacity','bfxr','sound','wave') $icons ) | Where-Object { $_ }
    quip='If it screeches, it teaches.'
  },
  [ordered]@{
    id='Q5'; phase='Logic'; title='Code of the Abyss'; color=$phaseColors.Logic
    purpose='Item behavior & GUI.'
    core=@('MCreator','VS Code')
    optional=@('IntelliJ IDEA','JSON viewers')
    icons=@(
      Find-Icon @('coding','logic','bc_icon_coding') $icons
    ) | Where-Object { $_ }
    quip='If it compiles, aim higher.'
  },
  [ordered]@{
    id='Q6'; phase='Testing'; title='Bubbles & Blood'; color=$phaseColors.Testing
    purpose='Test, tweak, record.'
    core=@('Forge dev client','Minecraft')
    optional=@('OBS Studio / Game Bar')
    icons=@( Find-Icon @('testing','bug','play') $icons ) | Where-Object { $_ }
    quip='Press run. Observe chaos. Adjust variables.'
  },
  [ordered]@{
    id='Q7'; phase='Export'; title='Release the Beast'; color=$phaseColors.Export
    purpose='Build & share.'
    core=@('Gradle / MCreator Build','GitHub Releases')
    optional=@('Canva (poster)','Screenshots')
    icons=@( Find-Icon @('export','rocket','release') $icons ) | Where-Object { $_ }
    quip='Ship it—and duck.'
  }
)

$sideNodes = @(
  [ordered]@{
    id='VR'; label='VR Sculpting'; phase='Modeling'
    tools=@('Gravity Sketch','Tilt Brush','SculptGL')
    icon=( Find-Icon @('vr','bc_icon_vr') $icons )
    quip='Think it, sculpt it, break reality.'
  },
  [ordered]@{
    id='AI'; label='AI Tools'; phase='Logic'
    tools=@('ChatGPT','Gemini','Leonardo.ai')
    icon=( Find-Icon @('mindcore','ai','interface') $icons )
    quip='Ask the void for ideas.'
  },
  [ordered]@{
    id='NOTES'; label='Notes/Glossary'; phase='Portal'
    tools=@('Google Docs (Voice)','Notion','Otter.ai')
    icon=( Find-Icon @('notes','bc_icon_notes') $icons )
    quip='Say it out loud; capture the chaos.'
  }
)

$toolsMeta = [ordered]@{
  banner     = 'Mindscape: Mission Control — Shark Gun Mod Questline'
  phases     = $phases
  side_nodes = $sideNodes
}
$toolsMeta | ConvertTo-Json -Depth 10 | Set-Content -Path $ToolsMetaPath -Encoding UTF8

# --- Build quests_meta.json ---
$quests = @(
  [pscustomobject]@{ id='Q0'; title='The Fork in the Code';      phase='Portal';    xp=150; subs=@('Choose Path','Deploy Choice') },
  [pscustomobject]@{ id='Q1'; title='Mission Prep';               phase='Setup';     xp=200; subs=@('Folders','Forge Test') },
  [pscustomobject]@{ id='Q2'; title='Prototype the Shark Gun';    phase='Modeling';  xp=350; subs=@('Blockbench','Optional VR','Export Model') },
  [pscustomobject]@{ id='Q3'; title='Skin of the Shark';          phase='Texturing'; xp=400; subs=@('Find Texture','Pixelate','Map Model','Glow') },
  [pscustomobject]@{ id='Q4'; title='Echoes of the Deep';         phase='Sound';     xp=300; subs=@('Attack','Transform','Idle','Import') },
  [pscustomobject]@{ id='Q5'; title='Code of the Abyss';          phase='Logic';     xp=500; subs=@('Create Item','Assign Model','GUI Picker','Stats','Sounds') },
  [pscustomobject]@{ id='Q6'; title='Bubbles & Blood';            phase='Testing';   xp=250; subs=@('Particles','Animate','Tweak','Record Clip') },
  [pscustomobject]@{ id='Q7'; title='Release the Beast';          phase='Export';    xp=600; subs=@('Build JAR','Victory Shot','Publish (opt.)','Reflect') }
)

$xp_total = ($quests | Measure-Object -Property xp -Sum).Sum

$questsMeta = [ordered]@{
  project   = 'Mission Control — Shark Gun Questline'
  xp_total  = $xp_total
  phases    = $phaseColors
  quests    = $quests
  bill_note = 'Knowledge through mayhem.'
}
$questsMeta | ConvertTo-Json -Depth 10 | Set-Content -Path $QuestsMetaPath -Encoding UTF8

# --- Mini report to console ---
Write-Host ''
Write-Host 'Rebuild Complete' -ForegroundColor Green
Write-Host ("  asset_index → {0}" -f (ConvertTo-RelWebPath $AssetIndexPath))
Write-Host ("  tools_meta  → {0}" -f (ConvertTo-RelWebPath $ToolsMetaPath))
Write-Host ("  quests_meta → {0}" -f (ConvertTo-RelWebPath $QuestsMetaPath))
Write-Host ("  icons: {0}   backgrounds: {1}" -f $icons.Count, $backgrounds.Count)

# ================= Optional: Git auto-commit/push =================
if ($AutoCommit) {

  function Rel([string]$p) { ConvertTo-RelWebPath $p }

  function Git([string[]]$GitParams) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'git'
    $psi.Arguments = ($GitParams -join ' ')
    $psi.WorkingDirectory = $Root
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute = $false

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()

    if ($proc.ExitCode -ne 0) {
      throw "git $($GitParams -join ' ') failed ($($proc.ExitCode)): $stderr"
    }
    return $stdout
  }

  $rel1 = Rel $AssetIndexPath
  $rel2 = Rel $ToolsMetaPath
  $rel3 = Rel $QuestsMetaPath

  Write-Host "`n⏫ Staging generated files..." -ForegroundColor Cyan
  Git @('add','--',$rel1,$rel2,$rel3) | Out-Null

  $changes = git diff --cached --name-only 2>$null
  if (-not $changes) {
    Write-Host 'Nothing changed—no commit created.' -ForegroundColor Yellow
  } else {
    Write-Host "Committing: $Message" -ForegroundColor Cyan
    Git @('commit','-m',$Message) | Out-Null

    if (-not $NoPush) {
      $up = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
      if ($LASTEXITCODE -eq 0 -and $up) {
        Write-Host "Pushing to $up ..." -ForegroundColor Cyan
        Git @('push') | Out-Null
        Write-Host '✅ Push complete.' -ForegroundColor Green
      } else {
        Write-Host 'No upstream set. Skipping push (commit created locally).' -ForegroundColor Yellow
        Write-Host 'Tip: run  git push -u origin <branch>  once to set upstream.' -ForegroundColor DarkGray
      }
    } else {
      Write-Host 'Push disabled by -NoPush. Commit is local only.' -ForegroundColor Yellow
    }
  }
}

