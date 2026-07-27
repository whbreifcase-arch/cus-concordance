# build_library.ps1
# Build a single unit library for the CUS Miniature Tracker.
#
# The v0.6 faction files reference packets and traits BY ID. The tracker wants
# them INLINE, because a miniature carries its whole definition and never looks
# anything up. So this walks the faction files, resolves every packet_id and
# trait_id against the packet/trait tables, and emits one flat library.
#
#   in : CUS_FACTIONS/data/faction_*.json + packets*.json + traits.json
#   out: CUS_MINI_KIT/unit_library_v06.json
#        CUS_MINI_KIT/unit_library_v06.lua   (same JSON as a Lua string)
#
# -Encoding UTF8 EVERYWHERE. PowerShell 5.1 falls back to the ANSI codepage on
# BOM-less files, which double-encodes every non-ASCII character. That is what
# corrupted the old mod's library.

$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$data = Join-Path (Split-Path -Parent $here) "CUS_FACTIONS\data"
if (-not (Test-Path $data)) { throw "Cannot find faction data at $data" }

function Read-Json($path) {
    if (-not (Test-Path $path)) { return $null }
    return (Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json)
}

# ---- packet + trait tables ------------------------------------------------
$packets = @{}
foreach ($f in @("packets.json","packets_family.json","packets_generic.json","packets_bestiary.json")) {
    $j = Read-Json (Join-Path $data $f)
    if ($j -eq $null) { continue }
    foreach ($p in $j.packets) { $packets[$p.packet_id] = $p }
}

$traits = @{}
$tj = Read-Json (Join-Path $data "traits.json")
foreach ($t in $tj.traits) { $traits[$t.trait_id] = $t }

Write-Host ("packets: {0}   traits: {1}" -f $packets.Count, $traits.Count)

# ---- walk the factions ----------------------------------------------------
$factions   = @()
$unresolved = @{}
$totalUnits = 0

# faction_*.json AND library_*.json — the Generic Profile Library (44
# faction-agnostic retinue/sergeant/champion/elite profiles) lives in
# library_generic.json and has the same shape, so it is just another "faction".
$sourceFiles = @()
foreach ($pattern in @("library_*.json", "faction_*.json")) {
    $sourceFiles += Get-ChildItem (Join-Path $data $pattern) -ErrorAction SilentlyContinue
}
$sourceFiles | Sort-Object { -not $_.Name.StartsWith("library_") }, Name | ForEach-Object {
    $fj = Read-Json $_.FullName
    if ($fj -eq $null -or $fj.units -eq $null) { return }

    $units = @()
    foreach ($u in $fj.units) {

        # resolve packets by id -> full objects the tracker can render
        $up = @()
        foreach ($packetId in @($u.packets)) {
            $p = $packets[$packetId]
            if ($p -eq $null) { $unresolved["packet:$packetId"] = $true; continue }
            $grades = @()
            foreach ($g in @($p.grades)) {
                $grades += [ordered]@{ grade = $g.grade; successes = $g.successes; effects = @($g.effects) }
            }
            $up += [ordered]@{
                packet_id = $p.packet_id
                name      = $p.name
                verb      = $(if ($p.verb) { $p.verb } else { "ACTION" })
                dice      = $p.dice
                success   = $p.success
                range     = $(if ($p.range -ne $null) { $p.range } else { 0 })
                cost_ap   = $(if ($p.cost_ap -ne $null) { $p.cost_ap } else { 1 })
                reach     = [bool]$p.reach
                grades    = $grades
            }
        }

        # resolve traits by id -> { trait_id, name, note }
        $ut = @()
        foreach ($traitId in @($u.traits)) {
            $t = $traits[$traitId]
            if ($t -eq $null) { $unresolved["trait:$traitId"] = $true; continue }
            $ut += [ordered]@{ trait_id = $t.trait_id; name = $t.name; note = $t.note }
        }

        $units += [ordered]@{
            schema        = "cus-0.6-unit"
            definition_id = $u.definition_id
            name          = $u.name
            faction       = $fj.faction          # units inherit the faction name
            prefix        = $fj.prefix
            role          = $u.role
            tempo         = $u.tempo
            tool          = $u.tool
            temperament   = $u.temperament
            creature_type = $u.creature_type
            archetype     = $u.archetype
            rank          = $u.rank
            tier          = $u.tier      # Generic library only: Retinue/Sergeant/Champion/Elite
            slot          = $u.slot      # Generic library only: encounter slot cost
            base          = [ordered]@{
                shape   = $u.base.shape
                size    = $u.base.size
                mounted = [bool]$u.base.mounted
            }
            stats         = [ordered]@{
                max_wounds = $u.stats.max_wounds
                armour     = $u.stats.armour
                nerve      = $u.stats.nerve
                speed      = $u.stats.speed
                max_ap     = $u.stats.max_ap
            }
            traits        = $ut
            packets       = $up
        }
        $totalUnits++
    }

    $factions += [ordered]@{ faction = $fj.faction; prefix = $fj.prefix; units = $units }
    Write-Host ("  {0,-26} {1,3} units" -f $fj.faction, $units.Count)
}

if ($unresolved.Count -gt 0) {
    Write-Host ""
    Write-Host ("UNRESOLVED REFERENCES ({0}):" -f $unresolved.Count) -ForegroundColor Yellow
    $unresolved.Keys | Sort-Object | ForEach-Object { Write-Host ("  " + $_) -ForegroundColor Yellow }
}

# ---- write ----------------------------------------------------------------
$out  = [ordered]@{ cus_version = "0.6"; generated = "build_library.ps1"; factions = $factions }
$json = $out | ConvertTo-Json -Depth 12 -Compress

$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $here "unit_library_v06.json"), $json, $utf8)

# Lua form: one long-bracket string the Global script can decode at load.
$lua = "-- generated by build_library.ps1 - do not edit by hand" + "`n" +
       "CUS_LIBRARY_JSON = [==[" + $json + "]==]" + "`n"
[System.IO.File]::WriteAllText((Join-Path $here "unit_library_v06.lua"), $lua, $utf8)

Write-Host ""
Write-Host ("DONE: {0} factions, {1} units, {2:N0} bytes of JSON." -f $factions.Count, $totalUnits, $json.Length)
