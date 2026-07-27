# CUS — Tabletop Simulator

Two implementations live here. **`kit/` is the live one.** `mod/` is the older,
larger build, kept for its data and its build pipeline.

```
tts/
  icons/  ← shared PNG assets. The tracker hard-codes this path in ICON_BASE.
  kit/    ← THE ONE THAT RUNS. Per-miniature tracker + a Global that stamps
            units onto minis from an 81-unit library. No cards, no linking.
  mod/    ← the full mod: src/ + build/ + a 700-line Global.xml. Superseded,
            not deleted — it owns the bundler and the save-file generator.
  SPEC.md ← v0.6 canon change-spec for whoever edits either build
```

---

## kit/ — the live build

| File | Goes in |
|---|---|
| `Global_CUS_full.lua` | the mod's **Global** slot (Lua). Includes the embedded unit library. |
| `Miniature_Tracker.lua` | **each miniature's Object script** |
| — | **the UI (XML) slot stays EMPTY** |

**There is no XML.** Both scripts build their panels as strings and push them
with `UI.setXml()` at runtime. That is the single biggest reason this build is
healthier than `mod/`: one source of truth, and no way for the Lua and the XML
to drift out of lockstep — which is exactly what blanked the mod's UI.

### The flow
Right-click a miniature → **CUS: Unit Library** → pick a faction → tap a unit →
it is stamped onto that mini. No card, no linking step.

### Regenerating the library
`build_library.ps1` walks `../../factions/data/`, resolves every `packet_id` and
`trait_id` into full objects, and emits `unit_library_v06.json` + `.lua`. The
faction files store references; the tracker wants whole objects, because a
miniature carries its entire definition and never looks anything up.

Run it after editing any faction, then re-paste Global.

> ⚠ **Always pass `-Encoding UTF8`.** PowerShell 5.1 falls back to the ANSI
> codepage on BOM-less files, reads a UTF-8 middle dot (`C2 B7`) as two
> characters, and writes it back double-encoded — permanently. That bug baked
> 143 corrupted characters into the mod's generated library.

---

## mod/ — superseded, retained

The full mod: `src/` (35 Lua files + `Global.xml`), `build/` (bundler, library
assembler, save-file generator), `docs/`, `tests/`.

**Why it is not the live build:** it needs cards, linking, and a static
`Global.xml` kept in lockstep with 4,200 lines of Lua. `kit/` needs a miniature
and nothing else.

**Why it is still here:**
- `build/make_save.ps1` bakes Lua + XML into a loadable TTS save (slot 20), so
  there is no pasting at all. That trick is worth keeping.
- `build/bundle.ps1` and `build/assemble_library.ps1` are working build steps.
- Its last commit fixed three real bugs, documented below.

### The three bugs its last commit fixed
1. **`UI.setXmlTable(rows, "element_id")` was replacing the entire global UI.**
   TTS's signature is `setXmlTable(xmlTable, assetTable)` — the second argument
   is the custom asset table, **not** an element to scope into. Five call sites
   did this; opening any of them blanked every panel. TTS has no supported
   "replace the children of X" call, so lists now use pre-declared slots driven
   by `UI.setAttribute`.
2. **The mojibake was the build scripts, not the paste.** See the encoding
   warning above.
3. **Buttons with no `color` attribute render white** — which is why a
   stretched white button looked like a blank sheet.

---

## SPEC.md

The v0.6 canon change-spec: what to rename, what to delete, what to add, and
four real bugs, each with the rule citation behind it. Written to be applied to
*any* build rather than as code.

The headline item is **REACTION** — a Kernel Resource in its own right (A·IV),
spent on someone else's activation, never paid out of AP, and the cap on every
triggered PACKET in the game. Neither TTS build represents it yet.

---

## Known gaps in both builds

- **Attacks still resolve on v0.5 Tiers**, not discrete Grades (A·VI, Model 2).
- **Charge has not split into Sprint + Impact** (B·3), and neither build reports
  the 3″ sprint→charge threshold.
- **Form Up** (B·11) — the Sergeant's group MOVE. Needs multi-object selection.
  The biggest missing mechanic.
- **Reaction** — see SPEC.md.
