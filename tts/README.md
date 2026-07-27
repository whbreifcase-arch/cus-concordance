# CUS — Tabletop Simulator

The playable implementation. Two scripts, both drop-in.

| File | Goes in |
|---|---|
| [CUS_Miniature_Tracker.lua](CUS_Miniature_Tracker.lua) | each miniature's **Object Lua** |
| [Global.lua](Global.lua) | the mod's **Global Lua** (the Attack Controller) |

Paste, press **Save & Play**. No JSON to import — the tracker pulls units from
this repo (see below).

---

## The HUD

```
   [yellow]  [blue]    [heart]   [triangle]
   REACTION    AP       WOUNDS   ACTIVATION
     ●         ●         ♥ 2         △
     ●         ●
     ○         ●
                MOVE  ATK  WAIT  ↻
```

- **Yellow column — REACTION.** Spent on *someone else's* activation: Counter,
  Shield Intercept, Reach strike, a firing Overwatch. `1` per figure, `2` for a
  Circle (B · 12). Empty column, and the figure cannot respond at all.
- **Blue column — AP / Agency.** Spent on your *own* activation. The two pools
  never exchange (A · IV), which is why they are two columns and not one bar.
- **Heart** — one heart with the Wounds remaining written on it. `☠` at zero.
- **Triangle** — `△` unactivated · `▲` waiting (a WAIT is armed) · `▽` activated.

Left-click spends, right-click restores, on every readout.

### The action row
```text
MOVE   opens the ruler and starts tracking · click again to close
ATK    fires the Attack Controller, then click your target
WAIT   1 AP to arm — and it warns you it still costs a Reaction to fire
↻      ACTIVATION refresh: AP + Reaction restored, WAIT expired, path cleared
```

`↻` is an **activation** refresh, not a round-wide one. A figure refreshes at the
start of *its own* activation (B · 12) — which is exactly why a figure that
emptied its pool late last round walks into this one still empty.

---

## The Unit Library

Right-click → **CUS: Unit Library**. Nine tabs, pulled live over HTTPS from:

```
raw.githubusercontent.com/whbreifcase-arch/cus-kernel-rebuild/main/factions/data/
```

Generic · Templars · Mordor · Militia · Goblins · Lizardfolk · Ponies · Dragon ·
Bestiary. Click a profile and the figure is stamped.

Units reference packets and traits **by ID** (`"packets": ["gen_1h"]`) because a
Definition is written once and referenced everywhere (Law 1). The tracker fetches
`packets*.json` and `traits.json`, merges them into one lookup, and resolves those
IDs into full objects before loading. Packets and traits are cached; **RELOAD**
drops the cache and re-fetches.

**A balance change committed to `factions/data/` is live on the next pick.**
Nothing to re-export, nothing to re-import.

---

## The Attack Controller

Right-click → **CUS: Attack**, then click the target. It reads the geometry and
tells you what it means:

- **`BASE CONTACT — this packet is not_in_contact`** — Reach carries the
  constraint by definition, ranged carries it by default (B · 5). Swing Fists.
  A packet may opt out with `"not_in_contact": false` — that's a wrist crossbow,
  and it is a priced advantage.
- **`OUT OF REACH`**, with the real gap between bases.
- In contact: *expect a Counter (1 Reaction).* Out of contact: *no engagement,
  no Counter* — ranged never engages (B · 8).

After a melee-in-contact roll it prints the Counter rules, including **both
lethal → BOTH DIE**, and reminds you Grades are **discrete** — resolve only the
line you reached (A · VI).

**It automates nothing.** It never spends AP or Reaction, never rolls Armour,
never applies an effect. It removes friction; it does not enforce.

---

## Movement

The ruler reports the **3″ sprint→charge threshold** (B · 3):

```text
MOVE  7.4" / 8.0"   run-up 2.1"/3"     ← not yet a charge
MOVE  7.4" / 8.0"   CHARGE 3.6"        ← earned it
```

It measures the **final leg only**, because a committed waypoint means the figure
turned and the run-up has to be straight. Contact and interruption stay the
players' call — the ruler reports geometry, it does not adjudicate.

---

## Not implemented yet

- **Form Up** (B · 11) — the Sergeant's group MOVE. Needs multi-object selection
  and shape handling. The biggest missing mechanic.
- **The Nerve test** — 3 dice vs Nerve (B · 10). Rolled by hand for now.
- **Harm / the Aftermath** (H · 7–8) — between-battle, so it belongs in the
  companion app rather than the table.
