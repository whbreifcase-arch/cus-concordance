# Setup

## A. Install the scripts

### Option 1 — Official TTS Lua extension (recommended for editing)
1. Install the **Tabletop Simulator Lua** extension (VS Code or Atom).
2. In TTS: *Scripting → Save & Play* once to create the working folder, then
   copy the contents of `src/` into that folder (keep the `core/ modules/ ui/
   objects/ data/` sub-paths — the `#include` lines are relative to `src/`).
3. Open **Global** in the extension and *Save & Play*. The `#include` lines in
   `src/Global.lua` are resolved automatically.
4. In TTS, open the **Global UI (XML)** editor and paste `src/Global.xml`.
5. Save the game.

### Option 2 — Hand-paste (no extension)
1. From the `CUS_TTS_MOD` folder run:
   ```
   powershell -ExecutionPolicy Bypass -File build/bundle.ps1
   ```
   This writes `build/Global.bundled.lua` (all `#include`s inlined).
2. In TTS: *Scripting* → paste `build/Global.bundled.lua` into the **Global Lua**
   slot and `src/Global.xml` into the **Global XML** slot → *Save & Play*.

Either way, when the mod boots you'll see a **Round** panel (top-right) and a
console line: *"CUS controller ready."*

## B. Put units on the table

### Fastest: the built-in fixture
Click **Spawn Test Fixture** on the Round panel. It spawns two scripted cards
and two scripted miniatures (Militia Swordsman vs Goblin Warboss) and auto-links
them. You can immediately run every acceptance test.

### Production: your own objects
1. **Card object** — any tile/card. Paste `src/objects/CardController.lua` onto
   it. Put the unit's structured definition JSON into its **GM Notes** (copy one
   entry from `src/data/sample_units.json`), then right-click →
   *Load Definition From GM Notes*. The card now answers `getDefinition()`.
2. **Miniature object** — any figure/block. Paste
   `src/objects/MiniatureController.lua` onto it.
3. **Link them** (two supported flows, both selection-based — TTS has no global
   object-click event):
   * Select the miniature, right-click the **card** → *Link Selected Miniature*.
   * Select the card, right-click the **miniature** → *Link Selected Card*.
   On link, current Wounds/AP initialise from the card's maxima (once), and the
   pair flash green.

## C. Packets
The Global packet registry loads `data/sample_packets` at boot. To use your own,
edit `src/data/sample_packets.lua` (or `.json` and load it your preferred way).
Cards reference packets by **ID**; changing a packet updates every card that
uses it.

## D. Facing calibration
Right-click a miniature → *Calibrate Forward Axis* to cycle its forward axis
(`local_z → local_x → local_-z`) until it matches the model's "front." Facing
drives Flank (+1 die) and Rear/Backstab (+2 dice, no Counter).

See [`HOTKEYS.md`](HOTKEYS.md) and [`SAVELOAD.md`](SAVELOAD.md) next.
