Param(
  [Parameter(Mandatory=$false)][string]$ItemId,
  [Parameter(Mandatory=$false)][string]$DisplayName
)

function Read-NonEmpty($prompt){
  do { $v = Read-Host $prompt } while([string]::IsNullOrWhiteSpace($v))
  return $v
}

if(-not $ItemId){ $ItemId = Read-NonEmpty "Enter item id (snake_case, e.g. shark_gun)" }
if(-not $DisplayName){ $DisplayName = Read-NonEmpty "Enter display name (e.g. Shark Gun)" }

$root = Get-Location
$resources   = Join-Path $root "src\main\resources"
$assetsDir   = Join-Path $resources "assets\sharkgun"
$langDir     = Join-Path $assetsDir "lang"
$modelsDir   = Join-Path $assetsDir "models\item"
$texturesDir = Join-Path $assetsDir "textures\item"

$javaDir   = Join-Path $root "src\main\java\com\sam\sharkgun"
$modItems  = Join-Path $javaDir "ModItems.java"

# Ensure directories
foreach($d in @($langDir,$modelsDir,$texturesDir)){ if(-not (Test-Path $d)){ New-Item -ItemType Directory -Path $d | Out-Null } }

# Language file
$langPath = Join-Path $langDir "en_us.json"
$lang = @{}
if(Test-Path $langPath){ try { $lang = Get-Content $langPath -Raw | ConvertFrom-Json -AsHashtable } catch { $lang = @{} } }
$lang["item.sharkgun.$ItemId"] = $DisplayName
$lang | ConvertTo-Json -Depth 5 | Out-File -FilePath $langPath -Encoding utf8

# Model JSON
$modelPath = Join-Path $modelsDir "$ItemId.json"
$model = @{ parent="item/generated"; textures=@{ layer0="sharkgun:item/$ItemId" } }
$model | ConvertTo-Json -Depth 5 | Out-File -FilePath $modelPath -Encoding utf8

# 1x1 transparent PNG placeholder
$pngPath = Join-Path $texturesDir "$ItemId.png"
if(-not (Test-Path $pngPath)){
  $b64="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
  [IO.File]::WriteAllBytes($pngPath, [Convert]::FromBase64String($b64))
}

# Modify ModItems.java via markers (if present)
if(Test-Path $modItems){
  $content = Get-Content $modItems -Raw
  $CONST = $ItemId.ToUpper().Replace("-","_")
  $decl  = "public static final net.minecraftforge.registries.RegistryObject<net.minecraft.world.item.Item> $CONST = ITEMS.register(`"$ItemId`", () -> new net.minecraft.world.item.Item(new net.minecraft.world.item.Item.Properties()));"
  $content = $content -replace "(// AUTOGEN-REGISTRY-START\s*)([\s\S]*?)(\s*// AUTOGEN-REGISTRY-END)", ('$1' + "`n    " + $decl + "`n" + '$2' + '$3')
  $hook = "// (DeferredRegister auto-handles registration)"
  $content = $content -replace "(// AUTOGEN-REGISTER-START\s*)([\s\S]*?)(\s*// AUTOGEN-REGISTER-END)", ('$1' + "`n    " + $hook + "`n" + '$2' + '$3')
  $content | Out-File -FilePath $modItems -Encoding utf8
} else {
  Write-Host "WARNING: $modItems not found. Skipping Java edits. Add registry lines manually." -ForegroundColor Yellow
}

Write-Host "Created:" -ForegroundColor Cyan
Write-Host " - $langPath"
Write-Host " - $modelPath"
Write-Host " - $pngPath"
Write-Host ""
Write-Host "Drop a custom PNG at:" -ForegroundColor Cyan
Write-Host " $texturesDir\$ItemId.png"
Write-Host ""
Write-Host "Use in-game:" -ForegroundColor Cyan
Write-Host " /give @p sharkgun:$ItemId"
