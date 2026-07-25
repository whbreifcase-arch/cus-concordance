# CUS FACTIONS — Templars vs Mordor · a full v0.6 build
### Two complete factions, a from-scratch spatial combat engine, balance sims, banners & a 3D replay. 2026-07-24

Built native to **`CUS_KERNEL_REBUILD/`** (v0.6, CLOSED). No old vocabulary, no
recycled Module-K. Roles are **Pressure · Anchor · Utility** only; results are
**Success Grades (Model-2 discrete)**; verbs are **MOVE · ACTION · WAIT**.

```
CUS_FACTIONS/
├─ DESIGN.md              the design doc — lore, rosters, every Grade ladder
├─ README.md             this file
├─ BALANCE_REPORT.md     the sim results + tuning journey + honest analysis
├─ BANNER.html           ← OPEN THIS: both factions, every unit card, all Grades
├─ BATTLE_3D.html        ← OPEN THIS: 3D isometric replay of an assault on the gate
├─ data/                 the v0.6 game data (this IS the faction content)
│  ├─ packets.json          30 PACKETs (weapons + abilities) with Grade ladders
│  ├─ packet_index.json     the neutral-ID sidecar (A.V) — classification
│  ├─ traits.json           referenced passive Definitions (B.14)
│  ├─ faction_templar.json  Order of the Argent Templar — 11 figure Definitions
│  └─ faction_mordor.json   The Iron Horde of Mordor — 12 figure Definitions
└─ sim/                  the engine + tools (Python 3.11, stdlib only)
   ├─ engine.py            v0.6 combat engine: spatial (x,y,z), Grades, effects,
   │                       Counter, Nerve, Push/Indent/Crush, elevation LoS
   ├─ game.py              procedures + Temperament AI + alternation runner
   ├─ loader.py            loads the v0.6 JSON into engine Definitions
   ├─ scenarios.py         5 mechanic tests (charge, reach-lane, high-ground, counter)
   ├─ balance.py           points pricing + parallel round-robin (all cores)
   ├─ make_banner.py       regenerates BANNER.html from the data
   └─ render3d.py          regenerates BATTLE_3D.html
```

## The two factions

| | **Order of the Argent Templar** ("space marines") | **The Iron Horde of Mordor** ("space orks") |
|---|---|---|
| Identity | Few, elite, Heavy armour, disciplined | Many, cheap, expendable, furious |
| Force profile | **Anchor**-heavy — deny, endure, execute | **Pressure**-heavy — overwhelm before they set |
| Roles used | Pressure · Anchor · Utility | Pressure · Anchor · Utility |
| Champion | Grand Master Aldric (Circle/Large, W4, 4-die Execute blade, Smite, Rally) | Uruk Captain Gûlthak (Circle/Large, W5, 4-die Execute cleaver) + Cave Troll (W7, Unstoppable) |
| Distinct math | reliable 3+/4+, Guard/Shield-Wall, mixed Medium/Heavy | swingy 4+/5+, more bodies, mob bonus, chaff into the Counter |
| 11 / 12 units | see BANNER.html | see BANNER.html |

## Run it yourself

```powershell
$py = "C:\Users\WH407\AppData\Local\Programs\Python\Python311\python.exe"
cd C:\Users\WH407\Downloads\forge\CUS_FACTIONS\sim

& $py loader.py            # print both rosters
& $py scenarios.py         # 5/5 mechanic tests (charge, reach-lane, high-ground, counter, full game)
& $py balance.py           # points price table
& $py balance.py rr 3000 380   # 3000-game parallel round-robin at 380 pts
& $py make_banner.py       # rebuild BANNER.html
& $py render3d.py          # rebuild BATTLE_3D.html
```

## What the engine implements (all SIGNED v0.6 rules)

- **Spatial with elevation** — continuous (x,y) inches + a real z axis. Walls block
  movement & line-of-sight; platforms/hills give elevation with **climb cost per
  story** (B.2); **LoS is interpolated in 3D** so a shooter on high ground sees over
  a low wall and gets **+1 die**; a **downhill Impact** gets +1.
- **PACKET → count Successes → Success Grade, Model-2 discrete** (A.VI, B.5).
- **Effects**: Wound (+ Armour save per Wound), Push, Pull, Knockdown, Guard,
  Cleave, Execute, ignore Armour, Terror.
- **Counter** (B.9): turn-and-face, **no cap, the dying swing lands**, Circles
  faceless (always Counter), flank/rear denial on an already-engaged Square, a
  Reach strike suffers no Counter, a Counter never draws a Counter.
- **Nerve** (B.10): Squares (Man/Beast) test on a shock (Wounded, or a friendly
  falls within 3″); roll **3 dice**, success = die ≥ Nerve; 0 = step down, 1–2 =
  hold, 3 = step up; **Steady → Shaken → Broken**; Broken = **Rout by Temperament**.
- **Sprint → Impact → Push/Indent/Crush** geometry (B.3, B.4); mounted plows one
  class up; Small doesn't plow; wall-crush feeds the hit.
- **Temperament AI** (Cowardly/Resolute/Aggressive/Protective/Ravenous) driving
  approach, charge, gang-up, reach-hold, kiting, and Rout behaviour.

See **BALANCE_REPORT.md** for the validation and balance numbers.
