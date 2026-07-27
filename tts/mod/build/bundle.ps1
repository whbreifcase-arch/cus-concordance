# build/bundle.ps1 — inline every `#include path` line in Global.lua into one
# self-contained Global.bundled.lua you can paste straight into TTS's Global
# script slot (for people not using the official TTS Atom/VSCode extension).
#
# Usage (from the CUS_TTS_MOD folder):
#     powershell -ExecutionPolicy Bypass -File build/bundle.ps1
#
# Output: build/Global.bundled.lua

$ErrorActionPreference = "Stop"
$root  = Split-Path -Parent $PSScriptRoot
$src   = Join-Path $root "src"
$entry = Join-Path $src "Global.lua"
$out   = Join-Path $PSScriptRoot "Global.bundled.lua"

function Expand-Includes {
    param([string]$file, [System.Collections.Generic.HashSet[string]]$seen)
    # -Encoding UTF8 is REQUIRED — see the note in assemble_library.ps1. Most
    # src/*.lua files carry no BOM, so without this every em-dash, middle dot
    # and arrow in the source is mangled on its way into the bundle.
    $lines = Get-Content -LiteralPath $file -Encoding UTF8
    $sb = New-Object System.Text.StringBuilder
    foreach ($line in $lines) {
        if ($line -match '^\s*#include\s+(.+?)\s*$') {
            $inc = $matches[1].Trim()
            $incPath = Join-Path $src ($inc + ".lua")
            if (-not (Test-Path $incPath)) { $incPath = Join-Path $src ($inc + ".json") }
            if (-not (Test-Path $incPath)) {
                [void]$sb.AppendLine("-- [bundle] MISSING INCLUDE: $inc")
                continue
            }
            if ($seen.Contains($incPath)) {
                [void]$sb.AppendLine("-- [bundle] already included: $inc")
                continue
            }
            $null = $seen.Add($incPath)
            [void]$sb.AppendLine("-- ===== begin $inc =====")
            [void]$sb.AppendLine((Expand-Includes -file $incPath -seen $seen))
            [void]$sb.AppendLine("-- ===== end $inc =====")
        } else {
            [void]$sb.AppendLine($line)
        }
    }
    return $sb.ToString()
}

$seen = New-Object 'System.Collections.Generic.HashSet[string]'
$bundled = Expand-Includes -file $entry -seen $seen
Set-Content -LiteralPath $out -Value $bundled -Encoding UTF8
Write-Host "Wrote $out ($((Get-Item $out).Length) bytes)."
