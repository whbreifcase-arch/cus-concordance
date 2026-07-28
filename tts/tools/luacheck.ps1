# =============================================================================
# luacheck.ps1 — validate a TTS build with a REAL Lua parser before pasting it
# =============================================================================
#
#   powershell -ExecutionPolicy Bypass -File tts\tools\luacheck.ps1
#   powershell -ExecutionPolicy Bypass -File tts\tools\luacheck.ps1 tts\kit\Global_CUS.lua
#
# With no arguments it checks every .lua in tts\kit.
#
# WHY THIS EXISTS. luacheck.py was a brace-balance HEURISTIC written because
# there was no Lua on the machine — it counted block keywords and hoped. It also
# needs Python, and the only python.exe on this box is the Microsoft Store stub,
# so it could not run at all. This script uses the actual Lua compiler, which
# does not guess: if `luac -p` accepts the file, the file parses.
#
# IT BOOTSTRAPS ITSELF. On first run it fetches the official LuaBinaries MSI,
# verifies its SHA256 against the pinned hash below, and extracts it with an
# administrative install (`msiexec /a`) into a cache folder. Nothing is
# installed, no registry key is written, nothing touches PATH. Delete the cache
# folder and it is gone.
#
# TWO CHECKS ARE RUN:
#   1. PARSE      `luac -p` — the real thing.
#   2. GLOBALS    every global the file READS but never WRITES, minus a known
#                 allowlist of Lua stdlib and TTS API names. This is the check
#                 that catches a call to a function you renamed or deleted:
#                 in Lua a vanished local silently becomes a nil global read,
#                 which parses perfectly and then throws at the table.
#
# WHAT IT STILL DOES NOT CATCH: genuine runtime errors — wrong argument shapes,
# nil indexing down a branch that only fires on a Tuesday. For those, the TTS
# console (`~`) is still the last word.
# =============================================================================

param([string[]]$Files)

$ErrorActionPreference = "Stop"

# --- the pinned toolchain ----------------------------------------------------
# LuaBinaries 5.4.6, the same artifact winget's DEVCOM.Lua package installs.
# The hash is checked on every download; a mismatch aborts rather than running
# an unknown binary.
$LUA_URL  = "https://github.com/DevelopersCommunity/cmake-lua/releases/download/v5.4.6/Lua-5.4.6-win64.msi"
$LUA_SHA  = "1087abb5aca89cad29283a17745ac2819aa46ca076084e8b3416db87d2694ed8"
$CacheDir = Join-Path $env:LOCALAPPDATA "CUS\luatools"

function Get-Luac {
    # Already on PATH? Use it and skip the download entirely.
    $onPath = Get-Command luac.exe -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }

    # The MSI and the extraction target MUST be different folders: an
    # administrative install copies the .msi into TARGETDIR, and if that is
    # where the .msi already lives msiexec dies with a bare 1603.
    $pkgDir = Join-Path $CacheDir "pkg"
    $dlDir  = Join-Path $CacheDir "dl"
    $luac   = Join-Path $pkgDir "Lua\bin\luac.exe"
    if (Test-Path $luac) { return $luac }

    Write-Host "luac not found - fetching the pinned LuaBinaries build (one time)..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $pkgDir | Out-Null
    New-Item -ItemType Directory -Force -Path $dlDir  | Out-Null
    $msi = Join-Path $dlDir "lua.msi"
    Invoke-WebRequest -Uri $LUA_URL -OutFile $msi -UseBasicParsing

    $got = (Get-FileHash $msi -Algorithm SHA256).Hash.ToLower()
    if ($got -ne $LUA_SHA) {
        Remove-Item $msi -Force
        throw "SHA256 mismatch on the Lua download. Expected $LUA_SHA, got $got. Refusing to run it."
    }

    # /a is an ADMINISTRATIVE install: it unpacks the payload to TARGETDIR and
    # installs nothing. No elevation, no registry, no PATH change.
    $p = Start-Process msiexec.exe -ArgumentList "/a `"$msi`" /qn TARGETDIR=`"$pkgDir`"" -Wait -PassThru -NoNewWindow
    if ($p.ExitCode -ne 0) { throw "msiexec extraction failed with exit code $($p.ExitCode)." }
    if (-not (Test-Path $luac)) { throw "Extraction completed but luac.exe is not at $luac." }

    Remove-Item $dlDir -Recurse -Force -ErrorAction SilentlyContinue
    return $luac
}

# Lua standard library + the Tabletop Simulator API surface these builds use.
# A global read that is NOT in here and NOT assigned by the file itself is
# almost always a typo or a reference left behind by a deletion.
$ALLOW = @(
    # Lua stdlib
    'assert','collectgarbage','coroutine','debug','dofile','error','getmetatable',
    'io','ipairs','load','loadstring','math','next','os','pairs','pcall','print',
    'rawequal','rawget','rawlen','rawset','require','select','setmetatable',
    'string','table','tonumber','tostring','type','unpack','xpcall','utf8','_G',
    # TTS globals
    'self','Global','Player','Turns','Wait','JSON','UI','Color','Grid','Lighting',
    'Notes','Physics','Time','WebRequest','Clock','Counter','Backgrounds','Hands',
    'broadcastToAll','broadcastToColor','getObjectFromGUID','getAllObjects',
    'getObjects','spawnObject','spawnObjectJSON','destroyObject','copy','paste',
    'group','startLuaCoroutine','log','logString','printToAll','printToColor',
    'getSeatedPlayers','getPlayerCount','onLoad','onSave','onUpdate','onFixedUpdate',
    'onDrop','onPickUp','onCollisionEnter','onCollisionExit','onDestroy',
    'onPlayerAction','onPlayerConnect','onPlayerDisconnect','onPlayerChangeColor',
    'onObjectDrop','onObjectPickUp','onObjectDestroy','onChat','onScriptingButtonDown',
    'onScriptingButtonUp','onExternalMessage','onBlindfold','onPlayerTurn'
)

$luac = Get-Luac
if (-not $Files -or $Files.Count -eq 0) {
    $root  = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $Files = Get-ChildItem (Join-Path $root "tts\kit") -Filter *.lua | ForEach-Object { $_.FullName }
}

$failed = 0
foreach ($f in $Files) {
    if (-not (Test-Path $f)) { Write-Host "MISSING     $f" -ForegroundColor Red; $failed++; continue }
    $name = Split-Path $f -Leaf

    # ---- 1. parse ----------------------------------------------------------
    $out = & $luac -p $f 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "PARSE FAIL  $name" -ForegroundColor Red
        $out | ForEach-Object { Write-Host "            $_" -ForegroundColor Red }
        $failed++
        continue
    }

    # ---- 2. globals --------------------------------------------------------
    # GETTABUP _ENV "x" is a read of global x; SETTABUP _ENV "x" is a write.
    # Anything read but never written and not on the allowlist is suspect.
    $dump  = & $luac -l -l -p $f 2>&1
    $reads = @(); $writes = @()
    foreach ($line in $dump) {
        if ($line -match '\bGETTABUP\b.*_ENV "([A-Za-z_][A-Za-z0-9_]*)"') { $reads  += $Matches[1] }
        if ($line -match '\bSETTABUP\b.*_ENV "([A-Za-z_][A-Za-z0-9_]*)"') { $writes += $Matches[1] }
    }
    $unknown = $reads | Sort-Object -Unique | Where-Object { $ALLOW -notcontains $_ -and $writes -notcontains $_ }

    if ($unknown.Count -gt 0) {
        Write-Host "PARSE OK    $name" -ForegroundColor Green
        Write-Host "  SUSPECT GLOBALS (read, never assigned, not a known API name):" -ForegroundColor Yellow
        $unknown | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
        Write-Host "  If one of these is a function you renamed or deleted, it will be nil at runtime." -ForegroundColor Yellow
    } else {
        Write-Host "PARSE OK    $name   (no suspect globals)" -ForegroundColor Green
    }
}

if ($failed -gt 0) { Write-Host "`n$failed file(s) FAILED to parse. Do not paste these." -ForegroundColor Red; exit 1 }
Write-Host "`nAll files parse. Safe to paste." -ForegroundColor Green
exit 0
