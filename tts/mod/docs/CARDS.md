# Unit library & card layout

## The unit library (pick a unit → stamp it onto a card)
The mod ships a catalog of **73 units across 5 factions** (Militia, Goblins,
Stormwarden, Orks, Sauron) — every faction has all five Roles plus **2 cavalry
and 2 monsters**. Source data lives in `src/data/factions/*.json`; it is
assembled into `src/data/unit_library.json` (external) and
`src/data/unit_library.lua` (embedded in the mod) by `build/assemble_library.ps1`.

**To make a card:**
1. Round panel → **Spawn Blank Card** (or use any object with the card script).
2. **Left-click the card** to select it.
3. Round panel → **Unit Library** (or right-click the card → *Open Unit Library*).
4. Pick a faction on the left, click a unit on the right. Its full definition is
   stamped onto the card (stats, packets, base, temperament, display). A linked
   miniature immediately reads the new stats.

Cavalry are tagged 🐎 and monsters 🐲 in the list.

### Editing / adding units
Edit the faction JSON in `src/data/factions/`, then re-run:
```
powershell -ExecutionPolicy Bypass -File build/assemble_library.ps1
powershell -ExecutionPolicy Bypass -File build/bundle.ps1
```
and re-paste `build/Global.bundled.lua`. The assembler validates each faction and
reports unit / cavalry / monster counts.

## Card layout — custom zones (edit once, use in both places)
There is ONE layout file, `card_layout.json`, that positions every stat/text
zone as **normalized coordinates** (0..1 of the card). Two editors read it:

### A) HTML Card Forge v3 (smooth drag editing)
Open `Downloads/cards/card_forge_v3.html` in a browser.
- **Drag** any labelled box to move it; drag the gold corner handle to resize.
- Arrow keys nudge; `[` / `]` change font size; `H` hides/shows a zone.
- Load `unit_library.json` to preview real unit values; pick faction/unit.
- **Download layout.json** (or Copy) and **Download card PNG**.

### B) In-TTS Card Layout Editor (live on the real card)
Right-click a card → **Edit Card Layout**. A panel lets you step through zones
and nudge X/Y/W/H/font, cycle alignment, and show/hide — the card's face
re-renders live. **Export JSON → console** prints the layout for paste-back;
**Import** accepts a pasted layout JSON; **Apply to all cards** re-renders every
card.

### Keeping the two in sync
`card_layout.json` (HTML) and `card_layout.lua` (mod) hold the same JSON.
Workflow: design in the HTML forge → Download `layout.json` → paste its contents
into the mod's **Import** box (instant), and/or into `src/data/card_layout.json`
+ `src/data/card_layout.lua` for a permanent default. Going the other way, the
mod's **Export** prints JSON you can save as `card_layout.json` and load in the
HTML forge.

## Notes / calibration
- The TTS card **face** is object-UI drawn on the card. The whole face's
  rotation/scale/offset is tunable via `card.ui_rotation`, `card.ui_scale`,
  `card.ui_position` in the layout's `card` block — a new card *shape* may need
  a one-time tweak so the face lies flat on it. Zone positions themselves are
  shape-independent (normalized).
- A card image (the CardViewer big panel) is separate: set
  `display.card_image_url` to a hosted PNG (e.g. a Card Forge v3 export uploaded
  somewhere) to show a full art card in the viewer. The face renderer needs no
  image — it draws the stats itself.
