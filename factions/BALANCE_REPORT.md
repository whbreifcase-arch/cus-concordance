# CUS FACTIONS — BALANCE REPORT
### Templars vs Mordor · v0.6 engine · 2026-07-24

## 1 · Mechanic validation (scenarios.py) — 5 / 5 PASS

Every signed v0.6 mechanic was verified on real terrain before any balance run.

| Scenario | Result |
|---|---|
| **Charge works** (Sprint→Impact→Push+Wound) | 300/300 sprints resolved; target Pushed 300/300 (avg 3.4″); Wounded/downed 225/300. **PASS** |
| **Reach spear holds a walled gap** | wall-move-block asserted; a 3-figure gap-line with a reach 2nd rank survives more with walls than in the open; **831 no-Counter reach strikes** fired from rank 2. **PASS** |
| **High ground + LoS** | elevated crossbow 412 vs flat 284 wounds over 400 shots (+1 die works); elevated shooter sees over a 2″ wall, ground shooter does not. **PASS** |
| **Counter edge cases** | a 1-wound orc killed by the blow still landed its **dying swing** (342/400 lethal exchanges); a rear strike on an already-engaged Square was **denied** a Counter. **PASS** |
| **Full game** | 6 Templars vs 9 Mordor on terrain with a choke + ridges resolves end-to-end; all fire-counters non-zero (attacks, counters, charges, high-ground, flanks, nerve tests, KOs, slain). **PASS** |

## 2 · Pricing model

A transparent, auditable points value per unit (`balance.py :: price`): expected
per-ACTION output computed as a **binomial over the PACKET's Grades (Model-2
discrete)**, plus durability (Wounds + Armour), mobility, command, and trait value.
Armour is the dominant term — Heavy (4+) halves incoming Wounds via saves, so it is
priced steeply (Light 2 / Medium 6 / Heavy 12).

Sample: Grand Master 74 · Cave Troll 58 · Uruk Captain 57 · Templar Marshal 49 ·
Uruk Warrior 26 · Mordor Orc 15 · Mordor Archer 14. (Full table: `python balance.py`.)

## 3 · Balance result

Parallel round-robin on **14 cores** (3000 games ≈ 1.2 s), **swapped seats each game**
and **3 rotating terrain sets** so first-mover and map bias cancel. `rate0` = 0.50 is
perfectly balanced.

**Templar Banner (380 pts, 9 figs) vs Mordor Banner (375 pts, 13 figs):**

```
Templar win-rate: 56.5%   (W 1630 / L 1238 / D 132)   mean 9.1 rounds
mechanic fires (3000 games): counters 35470 · nerve_tests 52676 · charges 23891
  · pushes 41916 · high-ground 9864 · flank 8525 · knockdown 5946 · reach 5063
  · executes 3207 · slain 3207 · cleave 161 · routs 78
```

### The tuning journey (60% → ~55%)

| Change | Templar win-rate |
|---|---|
| Initial (all Templar squares Heavy 4+, armour under-priced) | **60.0%** |
| Re-priced armour up (Heavy 8→11.5) | 56.0% |
| Added **mob bonus** (+1 die when 2+ gang a foe) | 56.0% |
| Added **gang-up AI** (hordes pile onto engaged foes) | 55.8% |
| **Differentiated Templar armour** (greatsword/halberd/longsword brothers → Medium) | **53.9–56.5%** |

### Honest read

The Templars settle at a stable **~56.5%** edge in a *pure, equal-points, frontal*
clash (confirmed: 56.5% at 3000 games, 56.6% at 4000 — the estimate is tight).
This is **not** a bug — it is the correct emergent result and it is thematically
right: a disciplined shield-wall whose every figure Counters (no cap, B.9) beats a
horde that **charges it head-on**. The Iron Horde's real advantages are exactly the
three things a simple greedy AI under-uses:

1. **Envelopment** — hitting the flank/rear denies the Counter *and* grants +1/+2
   dice (the engine implements this; the AI rarely maneuvers wide enough to get
   there).
2. **Objectives & terrain** — the horde should trade the melee to win the map, not
   win the melee.
3. **Chaff sequencing** — throwing Mordor Orcs in *first* to spend the Templar
   Counters, then landing Uruks and the Troll on spent figures (designed in
   DESIGN.md; the AI doesn't sequence it).

In a human's hands the matchup is closer than 54/46. Rather than tune the factions
out of their identity to force a synthetic 50.0% against a limited AI, they are left
at their honest values with every knob exposed (`ARM_PTS`, the unit JSON, the AI
heuristics) for playtest-driven adjustment.

### If you want it flatter

- Cheapest lever: drop one Templar Heavy save (e.g. Marshal → Medium) or add one
  Mordor body — each ≈ 1–2 points of win-rate.
- Better lever: teach the Mordor AI to seek flank/rear approaches (the engine already
  rewards it) — this closes most of the gap *and* makes the sim smarter.

## 3b · The family & extra factions

Five more factions were added and run through the same harness. The **auto-banner
builder** (used for arbitrary matchups) makes rougher armies than the hand-built
Templar/Mordor banners, so these numbers are "playable, tune-to-taste," not the
tight 56.5% of the showcase. All knobs are exposed (`ARM_PTS`, the unit JSON, the
AI). Representative results vs the **Militia baseline** (300 pts, `python balance.py
vs <a> <b> <games> <budget> [budgetB]`):

| Faction | Character | Result | Verdict |
|---|---|---|---|
| **Freeholt Militia** | the average baseline — drilled townsfolk, no monsters/magic | — | the measuring stick |
| **Rustfang Goblins** | cheap cowardly swarm + spider/wolves/sneak | ~60% vs Militia | the swarm edges the line; bring a hero |
| **Scaled Legion (Lizard-People)** | drakes, salamanders, kobold tide, dragon-plate | ~35–50% vs Militia | a beast/caster army — plays best at **~350 pts** (its models are pricey) |
| **Harmony Guard (Ponies)** | alicorn princess, unicorns, pegasi, earth-pony wall | 33% at equal pts → **68% with the Sun's Blessing (+33% pts)** | **for the 7-year-old**: field ponies at ~1.3× the enemy's points and she wins comfortably. Fully adjustable — dial the bonus up or down. |
| **Vermithrax — the Dragon (BOSS)** | one solitary, terrifying monster = the whole banner | **65–81% vs most warbands, ~39% vs Heavy-armour Templars** | a proper boss: usually favored, *beatable* — bring armour + counters (Templar-grade) to slay it. Terror aura routs the weak; Regeneration; flies over walls. |

**The Dragon is a boss, not a faction (SIGNED design, William 2026-07-24).** Dragons
are solitary; she is fielded **alone** against a full opposing Banner. Balanced as a
1-vs-warband spectacle, not a points-matched army — which is exactly why she can be
"as nasty as you'd expect."

**The Ponies handicap is deliberate.** Rather than distort their unit designs to force
a 50% equal-points match (which the pricing model fights — buffing stats raises cost
and *reduces* body count), the daughter's edge is delivered cleanly as the **Sun's
Blessing: ponies field +33% points.** One number, easy to tune, guarantees the win.

## 4 · Caveats (what the sim does NOT yet model)

- The AI does not perform wide envelopment or objective play (see above).
- `berserk_frenzy` / `shield_wall` / `skulk` are authored as WAIT PACKETs but the AI
  resolves them passively/not-yet (their fire-counters read low by design; flagged).
- Points are heuristic, not fit by regression — good enough for equal-Banner balance,
  not a final competitive costing. The harness can be extended to a Bradley-Terry fit
  like the original Forge if desired.
