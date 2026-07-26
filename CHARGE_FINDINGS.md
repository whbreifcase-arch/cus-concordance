# CUS — CHARGE: WHAT WE LEARNED
### v0.6 · capstone · closed 2026-07-25

The clash system is **done**. This is the distilled conclusion from ~1.3M+
simulated charges (`factions/sim/` — `clash_sim.py`, `study.py`, `holdtest.py`,
`angletest.py`; sandbox `play/CHARGE_LAB.html`). Governing spec: [[F_CLASH_RESOLUTION]].

## No new rules were added
Important: the sim did **not** author mechanics. Every rule it enforces already
existed in CUS — 1 reaction/figure, push→indent→crush (resolved lateral-first),
the 3″ run-up to count as a charge, the 3″ push cap, Square facing with flank/rear,
no-turn, Circles faceless, shields intercepting for an adjacent ally. The sim's job
was **conformance**: make sure all of the existing rules were honored together and
show how they interact at speed. The "findings" below are consequences of the
existing kernel, not additions. (Only nuance applied: shield interception used
*symmetrically* — a shield can soak for an adjacent ally on either side, per the
existing shield-reaction ruling.)

## The core works
A charge is not a special action — it's an emergent clash resolved inch-by-inch
under the normal activation/reaction economy. Those existing rules, run together,
produce real, emergent tactics with nothing scripted.

## What decides a clash (measured, ranked)
1. **Run-up is king.** No 3″ lane → the charge halts (no impact). Denying room is
   the strongest defensive act in the game (~81% hold vs the best charge).
2. **Depth punishes.** Each defensive rank roughly doubles the charger's casualties;
   reach-strikes scale straight with depth.
3. **Spears are defensive only.** Brutal to charge into (reach thins you on approach),
   near-useless as an attacking weapon.
4. **Lance/impact is the terror piece.** Pierces even deep prepared infantry.
5. **Shape by intent:** column = punch through · wedge = kill + flank angles · line = flat/weak.
6. **Angle:** the steeper the approach, the fewer casualties you take (denied counters)
   and the more flank/rear you land. Flanking trades cleaner, not necessarily deeper.

## The meta it grows
A charge *with room* is nearly unstoppable head-on — so the game moves **upstream of
contact**. The defensive game is **denying the lane** (spacing, screens, terrain,
zoning) first; mitigation (hedge, chaff screen — real, ~doubles your hold odds but a
coin-flip) second; tanking is not a strategy. The whole fight becomes a contest over
**room and facing**, decided before the lines meet — exactly as the design intended.

## Why the terror piece isn't broken (self-balancing)
The lance pierces — so it should be **priced as a terror weapon (expensive)** — but the
breakthrough *is* its own punishment: once through, it's spent, isolated, and **behind**
the enemy line, where the reformed rank, rear-facers, skirmishers and reserves turn and
flank *it*. Greedy "skewer clean through" is suicide; the skilled use is piercing a seam
or flank you can exploit **with support**. The rules punish misuse without a scripted counter.

## Where the modeling stops (on purpose)
The post-clash battle — reserves rushing in, healers, multi-front chaos, counter-charges,
utility plays (e.g. flashbang the wall before you hit it) — is **emergent and lives in the
players' hands**. Modeling it would require inventing arbitrary states and would make the
game worse, not truer. The sim's job was to prove the clash spine; it did. We stop here.

## Not modeled (known, deliberate)
- **Counter-charge** (both sides committing momentum) — the engine moves only the chargers;
  bidirectional clash is untested. It's the likely answer to a charge you can't prevent.
- **Objectives / multi-turn holding** — "positions stay held" is proven for the collision
  (denial works), not for a whole game; that needs a scenario layer.
- **The `impact`/lance flag grants no charge bonus in-sim** — the lancer wins on its stat
  line alone. If a lance should hit harder *because* it's charging, that's an unwired knob.

## Next (when wanted) — not more sim
Pricing (what a lance/shield/spear costs in slots) and scenarios/terrain (the room-denial
game). The combat spine is closed.
