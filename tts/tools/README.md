# Validating a build before you paste it

```
powershell -ExecutionPolicy Bypass -File tts\tools\luacheck.ps1
```

No arguments checks every `.lua` in `tts\kit`. Pass paths to check specific files.

## luacheck.ps1 — the real parser

Uses the **actual Lua compiler** (`luac -p`). If it accepts the file, the file
parses. No guessing.

On first run it downloads the official LuaBinaries 5.4.6 MSI, checks its SHA256
against a hash pinned in the script, and unpacks it with an administrative
install (`msiexec /a`) into `%LOCALAPPDATA%\CUS\luatools`. **Nothing is
installed** — no registry keys, no PATH changes, no elevation. Delete that
folder and the toolchain is gone. If `luac.exe` is already on PATH it uses that
and skips the download entirely.

### Two checks

**1 · PARSE.** `luac -p`. Unclosed blocks, unterminated strings and long
brackets — the failures that make TTS silently do nothing.

**2 · SUSPECT GLOBALS.** Every global the file *reads* but never *assigns*,
minus an allowlist of Lua stdlib and TTS API names.

This second one is the useful one. In Lua a deleted or renamed local silently
becomes a **nil global read** — it parses perfectly and then throws the moment
that line runs. Nothing catches that except looking, and this looks.

### One known warning, and it is correct

```
PARSE OK    Global_CUS.lua
  SUSPECT GLOBALS: CUS_LIBRARY_JSON
```

**Expected.** `Global_CUS.lua` is the slim build; the library string is assigned
in `unit_library_v06.lua`, which must be pasted above it in the same Global tab.
`Global_CUS_full.lua` is the same script with that string appended, and warns
about nothing. Leaving this warning un-suppressed is deliberate — it is a true
statement about a real cross-file dependency that is easy to forget.

### What it still does not catch

Genuine runtime errors: wrong argument shapes, a nil index down a branch that
only fires on a Tuesday. For those the TTS console (`~`) is still the last word.

---

## luacheck.py — superseded

The original checker: a dependency-free brace-balance **heuristic** that counted
block keywords, written because there was no Lua runtime on the machine. It was
honest about being a heuristic and it did catch real breakage.

It is kept for reference but **should not be relied on**, for two reasons: it
guesses where `luac` knows, and the only `python.exe` on this machine is the
Microsoft Store stub, so it cannot run at all. It reported success by exiting 0
without ever executing — which is worse than no checker.

Use `luacheck.ps1`.
