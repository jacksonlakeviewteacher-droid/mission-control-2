<#
    Rebuild Data Script
    -------------------
    Generates asset_index.json, tools_meta.json, and quests_meta.json
    for Mission Control – Shark Gun.
#>

$ErrorActionPreference = "Stop"

# --- Paths ---
$repo = Split-Path -Parent $MyInvocation.MyCommand.Definition
$root = Split-Path $repo
$dataPath = Join-Path $root "public\data"

$assetIndexPath = Join-Path $dataPath "asset_index.json"
$toolsMetaPath  = Join-Path $dataPath "tools_meta.json"
$questsMetaPath = Join-Path $dataPath "quests_meta.json"

# --- Functions ---
function Get-RelPath($path, $base = (Get-Location)) {
    return Resolve-Path $path | ForEach-Object {
        $_.Path.Replace((Resolve-Path $base).Path + "\", "")
    }
}

# --- Asset Index ---
Write-Host "Building asset index..." -ForegroundColor Cyan

$assetFiles = Get-ChildItem -Path (Join-Path $root "public") -Recurse -File |
    Where-Object { $_.Extension -match "\.(png|jpg|jpeg|mp3|wav|ogg|json)$" } |
    ForEach-Object {
        [PSCustomObject]@{
            name = $_.BaseName
            path = (Get-RelPath $_.FullName $root)
        }
    }

$assetFiles | ConvertTo-Json -Depth 5 | Set-Content -Path $assetIndexPath -Encoding UTF8


# --- Tools Meta ---
Write-Host "Building tools_meta.json..." -ForegroundColor Cyan

$toolsMeta = [ordered]@{
    banner = "Mindscape: Mission Control – Shark Gun Mod Questline"
    phases = @("Portal", "Setup", "Modeling", "Texturing", "Sound", "Logic", "Testing", "Export")
    side_nodes = @("Notes", "Quips", "Wallpapers", "Audio")
}

$toolsMeta | ConvertTo-Json -Depth 8 | Set-Content -Path $toolsMetaPath -Encoding UTF8


# --- Quests Meta ---
Write-Host "Building quests_meta.json..." -ForegroundColor Cyan

$quests = @(
    @{ id="Q0"; title="The Fork in the Code"; phase="Portal";   xp=150; subs=@("Choose Path","Deploy Choice") },
    @{ id="Q1"; title="Mission Prep";          phase="Setup";    xp=200; subs=@("Folders","Forge Test") },
    @{ id="Q2"; title="Prototype the Shark Gun"; phase="Modeling"; xp=350; subs=@("Blockbench","Optional Variants") },
    @{ id="Q3"; title="Skin of the Shark";     phase="Texturing"; xp=400; subs=@("Find Texture","Pixelate","UV Map") },
    @{ id="Q4"; title="Echoes of the Deep";    phase="Sound";     xp=300; subs=@("Attack","Transform","Idle") },
    @{ id="Q5"; title="Code of the Abyss";     phase="Logic";     xp=500; subs=@("Create Item","Assign Model","Stats","Sounds") },
    @{ id="Q6"; title="Bubbles & Blood";       phase="Testing";   xp=250; subs=@("Particles","Animate","Record Clip") },
    @{ id="Q7"; title="Release the Beast";     phase="Export";    xp=600; subs=@("Build JAR","Victory Shot","Reflect") }
)

$xp_total = ($quests | Measure-Object -Property xp -Sum).Sum

$questsMeta = [ordered]@{
    project = "Mission Control – Shark Gun Questline"
    xp_total = $xp_total
    phases = $toolsMeta.phases
    quests = $quests
    bill_note = "Knowledge through mayhem."
}

$questsMeta | ConvertTo-Json -Depth 8 | Set-Content -Path $questsMetaPath -Encoding UTF8


# --- Summary ---
Write-Host "`n✅ Rebuild complete!" -ForegroundColor Green
Write-Host "  asset_index.json → $assetIndexPath"
Write-Host "  tools_meta.json  → $toolsMetaPath"
Write-Host "  quests_meta.json → $questsMetaPath"
