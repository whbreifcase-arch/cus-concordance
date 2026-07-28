# CUS Tracker — change spec

Apply these to your own latest build. Written as *what and why*, not as code, so
you can implement them however your file is structured.

Ordered by importance. **§1 and §2 are correctness — the script currently
teaches players the wrong rules. §5 are outright bugs. Everything else is
features.**

Rule citations are to the CUS v0.6 docs (A = Kernel Constitution, B = Combat
Module, D = Migration Map).

---

# 1 · Canon renames — mechanical find/replace

| # | Find | Replace | Why |
|---|---|---|---|
| 1.1 | Nerve state `"Routed"` | `"Broken"` | The morale track is **Steady → Shaken → Broken** (B·10). *Rout* is what a Broken figure **does**, not a state it is in. |
| 1.2 | Turn state `"Readied"` | `"Waiting"` | `READY` is a **retired verb** — it became `WAIT` (D·1). |
| 1.3 | `definition.rank` | `definition.nerve` | `rank` was the old name for the Nerve stat. |
| 1.4 | `definition.tiers` | `definition.grades` | Ladder / Tiers / Rungs → **Success Grade** (A·VI). |
| 1.5 | `counter_uses` field | **delete entirely** | The `counter_x` economy is retired, and nothing replaced it — a Counter is free and **facing** is the cap (B·8, §2). |
| 1.6 | `TOOL_COLORS.utility` | `TOOL_COLORS.hybrid` | Combat's Tool set is **Melee · Ranged · Hybrid** (B·1). *Utility* is a **Role**, not a Tool. |

### 1.7 Migration, so saved figures don't reset
Both renames need a migration pass in `initializeRuntime()`, running **before**
the state is validated against the allowed list — otherwise a figure saved as
`"Routed"` silently resets to `Steady`.

```
if turn_state == "Readied" then turn_state = "Waiting" end
NERVE_MIGRATE = { Routed = "Broken", Breaking = "Broken" }
if NERVE_MIGRATE[nerve_state] then nerve_state = NERVE_MIGRATE[nerve_state] end
```

### 1.8 Legacy JSON must still read
Don't break existing unit files. Read `rank` and `tiers` as **fallbacks only**:

```
nerve  = stats.nerve  or root.nerve  or root.rank  or stats.rank
grades = packetGrades or display.grades or root.grades or display.tiers or root.tiers
```

⚠ **Careful:** `factions/data/library_generic.json` has **both** `stats.nerve`
*and* a `"rank": "I"` field, where `rank` there means something else (unit
tier). The fallback order above is correct — `stats.nerve` must win. Do not
map `rank → nerve` unconditionally.

### 1.9 Base size classes (B·1)
Canonical classes are **Small · Medium · Large only.** *Monstrous* and *Cavalry*
are retired — a monstrous figure is a **Large base + the `unstoppable` trait**,
and mounted is **elongated geometry, not a size class**.

```
Square:  Small 20mm   Medium 25mm   Large 40mm
Circle:  Small 25mm   Medium 32mm   Large 40mm
```

- Accept `"normal"` as an alias for `medium`, and `"monstrous"`/`"cavalry"` as
  aliases for `large`, so old JSON keeps working.
- **`mounted` must stack on top of the class, not replace it** — apply it as a
  separate check after the class lookup (`if mounted and diameter < 40 then
  diameter = 40`), not as another branch in the `elseif` chain. Otherwise a
  mounted Small resolves wrong.

---

# 2 · REACTION — ⚰ STRUCK 2026-07-27, DO NOT BUILD

**This section used to be the most important item in the document.** It specified a
`reactions` definition field, a `current_reactions` runtime pool, a yellow RP column
in the HUD, and a warning at zero.

**Build none of it.** The Reaction Resource was struck from the Kernel on 2026-07-27
(A·IV, B·12, E · `reaction-struck`). The tracker's RP column has been removed.

### What the tracker should represent instead
Nothing new — that is the point. Answering on someone else's activation is **free**,
and what limits it is not a number the tracker could hold:

```
POSITION   contact, facing, 1" for an intercept   — read off the table, not the HUD
AUTHORING  `provokes` on the striking packet      — a Definition, on the card
DEATH      wounds_remaining                        — already tracked
```

- **No `reactions` field.** If a library JSON ever carries one, ignore it.
- **No pool, no column, no warning at zero.** There is no zero.
- **A trigger fires once per occurrence** of its condition (A·III) — a bookkeeping
  rule for the players at the table, not state for the script to hold.

### 2.1 Refresh is still on ACTIVATION, not on the round
Per B·12 a figure refreshes **AP** and expires its armed WAIT at the start of **its
own** activation. The tracker must not quietly refill everyone at round start — that
part of the old spec was right and still is.

---

# 3 · WAIT should actually do something

Right now `Readied`/`Waiting` is a label with no cost. Make it real (A·III):

```
WAIT = spend 1 AP now to arm a chosen PACKET — and it fires
```

- Refuse if AP is 0.
- **Arming is permission** (amended 2026-07-27). The AP is the whole price; there is
  no second pool for it to fail against and **no warning to print.**
- Clicking WAIT while already Waiting should cancel the state (AP is not
  refunded).
- The armed WAIT **expires** when that figure next activates.

---

# 4 · Movement ruler — report the charge

The 3″ sprint→charge threshold (B·3): a Sprint becomes a **charge** when it
covers **3″ of uninterrupted straight run-up into contact.**

Add to the distance label:

```
MOVE  7.4" / 8.0"   run-up 2.1"/3"     ← not yet
MOVE  7.4" / 8.0"   CHARGE 3.6"        ← earned it
```

**Measure the final leg only** — the distance between the last committed
waypoint and the current endpoint. A path with a waypoint in it has turned, and
the run-up has to be straight.

Do **not** try to adjudicate contact or interruption; that stays with the
players (B·3, F). The ruler reports geometry.

---

# 5 · Bugs

### 5.1 Every heart click is silently dropped
```lua
string.sub(id, 1, 9) == "cus-heart-"
```
`"cus-heart-"` is **ten** characters. `sub(id, 1, 9)` yields `"cus-heart"`, which
never equals it. **Change 9 → 10.** (The AP pip check at `sub(id, 1, 11)` is
correct — `"cus-ap-pip-"` really is 11.)

### 5.2 Tooltips render as literal `&amp;#10;`
`xmlEscape()` converts `&` → `&amp;` **first**, so any tooltip written with a
literal `&#10;` and then passed through it comes out double-escaped and displays
as visible garbage.

Two valid fixes — pick one and be consistent:
- **(a)** Write tooltips with real `\n` and have `xmlEscape` convert `\n` →
  `&#10;` **after** the `&` escaping. (Your `Global.lua` already does this.)
- **(b)** Never pass a tooltip containing entities through `xmlEscape` at all.

Note `transparentButton()` escapes its tooltip argument; inline `tooltip="..."`
attributes in raw XML strings do not.

### 5.3 Pips / stacks render invisible
**TTS layout groups force-expand their children by default.** A `Panel`
containing `Text` + `Button`, nested inside a `VerticalLayout` inside a
`HorizontalLayout`, collapses to nothing.

- Put `childForceExpandWidth="false" childForceExpandHeight="false"` on **every**
  `HorizontalLayout` and `VerticalLayout`.
- Prefer plain `<Button text="●">` elements over nested `Panel > Text + Button`.
  Buttons render reliably; the original AP pip row worked for exactly this
  reason.

This is also what causes buttons to fly out of the panel to one side.

### 5.4 The movement panel cannot be closed
Two separate causes:
- The MOVE entry point only ever sets `move_panel_open = true`. **Make it a
  toggle** (and label it `CLOSE` while open).
- The panel's `✕` calls `clearMovementPath(true)` — and `true` means *keep the
  panel open*. It wipes the path and leaves the panel stuck. **Pass `false`.**

---

# 6 · Attack Controller (Global.lua)

It already computes centre distance and does nothing with it. Make it useful.

### 6.1 Base contact
Add a base-radius helper using the same table as §1.9, then:

```
gap = centreDistance - attackerRadius - targetRadius
inContact = gap <= ~0.15"
```

### 6.2 The `not_in_contact` constraint (B·5, B·8)
A packet may declare it cannot be resolved while bases are touching.

- **Reach packets carry it by definition.**
- **Ranged packets carry it BY DEFAULT** — you do not shoot a bow with a man on
  your base, you drop it and swing Fists.
- A packet may opt out with `"not_in_contact": false` — that is a wrist
  crossbow or a point-blank spell, and it is a **priced advantage**.
- Practical rule: treat any packet with `range > 0` as carrying it unless it
  explicitly opts out.

Show it: **`BASE CONTACT — this packet is not_in_contact. Swing Fists instead.`**
Also flag out-of-reach with the actual gap.

### 6.3 The Counter reminder
Only a **melee ACTION resolved in base contact** creates engagement and draws a
Counter. **Ranged never does** (B·8). After such a roll, print:

- Target Counters — one melee PACKET back, and it **costs nothing** (2026-07-27).
- Denied on the **unfaced flank/rear of a Square already engaged elsewhere**, or if
  the striking packet carries **`provokes: false`**. Circles are faceless and
  **always** Counter. Facing is the cap now — say so in the print.
- **If both the ACTION and the Counter are lethal, BOTH DIE.** No tiebreak.

### 6.4 Grades are discrete
Append to any result: *resolve **only** the line you reached — Grades do not
accumulate* (A·VI, Model 2).

### 6.5 Keep it manual
It should still spend nothing, roll no Armour, and apply no effects. Automation
belongs at friction-removal, not enforcement.

---

# 7 · HUD layout

*(The RP column was removed 2026-07-27 with the Reaction Resource — §2.)*

```
   [blue]          [heart]   [triangle]
   AP ● ● ○        WOUNDS   ACTIVATION
                    ♥ 2         △
                MOVE  ATK  WAIT  ↻
```

- **AP** — a **horizontal** row of circles, **blue**, reading left-to-right like a
  spend bar. Filled = still available, hollow = spent; horizontal fills
  left-to-right, vertical fills bottom-up. Getting the fill direction backwards
  looks broken even when the count is right.
- **Wounds** — **one** heart with the number on it, not a row of hearts. Wounds
  is 1–2 standard (B·7), so a row is noise. `☠` at zero.
- **Activation** — one triangle: `△` unactivated · `▲` waiting · `▽` activated.
  Point up = still has its turn, point down = spent.
- **Action row** — `MOVE · ATK · WAIT · ↻` permanently on the token, not behind
  a right-click menu. These four are the whole core loop.
- Panel height should follow the **taller** of the two columns, so a 2 AP figure
  doesn't reserve room for six.

---

# 8 · Unit Library — pull from the repo

Fetch over HTTPS with `WebRequest.get`. Base:

```
https://raw.githubusercontent.com/whbreifcase-arch/cus-kernel-rebuild/main/factions/data/
```

### 8.1 Files
Unit sources (all share the shape `{ faction, prefix, units: [ ... ] }`):

```
library_generic.json     44 generic profiles
faction_templar.json     faction_mordor.json    faction_militia.json
faction_goblin.json      faction_lizardfolk.json faction_pony.json
faction_dragon.json      faction_bestiary.json
```

Definition sources — merge all packet files into **one `packet_id → packet`
map**:

```
packets_generic.json   packets.json   packets_family.json   packets_bestiary.json
traits.json            (trait_id → trait)
```

### 8.2 Resolve IDs — this is the load-bearing part
Library units reference definitions **by ID**, because a Definition is written
once and referenced everywhere (Law 1):

```json
{ "name": "Shield-Bearer", "traits": ["shield"], "packets": ["gen_1h_shield"] }
```

The tracker's normalizer expects **full objects**. So before loading, replace
each ID with the object from the merged map. If an ID is missing, fall back to a
stub carrying just the ID as the name rather than dropping it silently.

Cache packets and traits after the first fetch; offer a **RELOAD** that clears
the cache.

### 8.3 On pick
Clear `current_wounds`, `current_ap` and the loaded
definition id **before** loading, so a different figure starts with full pools
rather than inheriting the previous one's damage.

### 8.4 The payoff
A balance change committed to `factions/data/` is **live on the next pick**.
No export, no import, no re-pasting JSON.

⚠ **The repo must be pushed for any of this to resolve.** As of writing, `main`
is several commits behind local.

---

# 9 · Not done — worth knowing

- **Form Up** (B·11) — the Sergeant-only group MOVE. Sergeant names unactivated
  friendlies within **4″**, shapes them, each pays **1 AP** and is **marked
  activated**, they MOVE as one body, and strikes/Shoves are declared **before
  contact**. You hit only what your own base moves into. Needs multi-object
  selection — a real feature, not a patch. **Biggest missing mechanic.**
- **Nerve test** — 3 dice vs the figure's Nerve; 0 successes steps down, 1–2
  hold, 3 steps up (B·10).
- **Harm / Aftermath** (H·7–8) — between-battle, belongs in the companion app.
