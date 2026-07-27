# build/make_save.ps1
# Generate a ready-to-load Tabletop Simulator save with the CUS mod already
# installed (Global Lua + UI baked in), placed directly in the TTS Saves folder.
# The user just opens TTS -> Games -> Save & Load and picks "CUS Playtest".
$ErrorActionPreference = "Stop"

$root      = Split-Path -Parent $PSScriptRoot
$luaPath   = Join-Path $root "build\Global.bundled.lua"
$xmlPath   = Join-Path $root "src\Global.xml"
$savesDir  = "C:\Users\WH407\Documents\My Games\Tabletop Simulator\Saves"
$slot      = 20
$savePath  = Join-Path $savesDir ("TS_Save_{0}.json" -f $slot)

if (-not (Test-Path $luaPath)) { throw "Missing $luaPath - run build/bundle.ps1 first." }
if (-not (Test-Path $xmlPath)) { throw "Missing $xmlPath" }

# Read as PURE .NET strings. (Get-Content -Raw decorates the string with ETS
# NoteProperties, which ConvertTo-Json then serializes as an object -> the save
# ends up with "LuaScript": { "value": ... } and TTS rejects it.)
$lua = [System.IO.File]::ReadAllText($luaPath, [System.Text.Encoding]::UTF8)
$xml = [System.IO.File]::ReadAllText($xmlPath, [System.Text.Encoding]::UTF8)

# JSON-escape each big string. -InputObject on a pure string yields a quoted
# JSON string literal (not an object).
$luaJson = ConvertTo-Json -InputObject $lua
$xmlJson = ConvertTo-Json -InputObject $xml

$epoch = [int][double]::Parse((Get-Date -UFormat %s))
$date  = (Get-Date).ToString("M/d/yyyy h:mm:ss tt")
$note  = "CUS kernel v0.6 playtest interface. Verbs: MOVE / ACTION / WAIT. Round panel (top-right): Spawn Test Fixture / Spawn Blank Card / Unit Library."

# Full save as literal JSON. TTS fills any omitted fields (Lighting/Grid/Hands/
# Turns...) with defaults on load. ObjectStates is empty - use the Spawn buttons.
$save = @"
{
  "SaveName": "CUS Playtest",
  "EpochTime": $epoch,
  "Date": "$date",
  "VersionNumber": "v14.2.1",
  "GameMode": "CUS Playtest",
  "GameType": "Game",
  "GameComplexity": "Medium Complexity",
  "PlayingTime": [0, 60],
  "PlayerCounts": [1, 8],
  "Tags": ["Wargames", "Miniature Games"],
  "Gravity": 0.5,
  "PlayArea": 0.5,
  "Table": "Table_Square",
  "Sky": "Sky_Museum",
  "Note": "$note",
  "LuaScript": $luaJson,
  "LuaScriptState": "",
  "XmlUI": $xmlJson,
  "ObjectStates": []
}
"@

# sanity: ensure it parses as JSON before writing
$null = $save | ConvertFrom-Json

# write UTF-8 WITHOUT BOM (TTS dislikes a leading BOM)
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($savePath, $save, $utf8)
Write-Host "Wrote $savePath"

# add an entry to SaveFileInfos.json so it shows immediately in the menu
$infoPath = Join-Path $savesDir "SaveFileInfos.json"
try {
  $infos = @(Get-Content -LiteralPath $infoPath -Raw | ConvertFrom-Json)
  $entry = [PSCustomObject]@{
    Directory  = $savePath
    Name       = "$slot - CUS Playtest - $date"
    UpdateTime = $epoch
  }
  $infos = @($infos | Where-Object { $_.Directory -ne $savePath }) + $entry
  $json = $infos | ConvertTo-Json -Depth 5
  [System.IO.File]::WriteAllText($infoPath, $json, $utf8)
  Write-Host "Updated SaveFileInfos.json (entry for slot $slot)."
} catch {
  Write-Host "Could not update SaveFileInfos.json ($($_.Exception.Message)); TTS will still find the save on its next folder scan."
}
Write-Host "DONE. In TTS: Games -> Save & Load -> 'CUS Playtest'."
