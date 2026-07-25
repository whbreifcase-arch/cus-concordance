# CUS — THE AI DIRECTOR
### v0.6 · running the enemies in PvE / PvAI · 2026-07-24

> How a human (or the sim) runs enemy figures with no thinking. It is not a new
> mechanic — it is **Temperament** (B·10) + **Missions** (A·XI) turned into a
> hand-runnable procedure. A player-facing card lives at `play/AI_DIRECTOR.html`.

## Two layers
- **Mission** — what the whole enemy force wants; set once per fight. It gives every
  figure a **Focus** (the point it moves toward when not already fighting):
  `OVERRUN` (reach the players' edge) · `DEFEND` (hold a place) · `DEVOUR` (kill all) ·
  `RAID` (grab objective, flee) · `HUNT` (converge on the nearest/weakest hero).
- **Figure** — how each enemy acts on its activation. Resolve the **first** rule that fits.

## Activation — first thing that fits
0. **Broken?** → Rout by Temperament (below), stop. *(Prone → 1 AP to stand.)*
- **Boss/leader?** → fire its special first: Raise a minion · Curse/Dread · Command.
- **Ranged + target in range & LoS?** → if Cowardly/Resolute, **shoot** (Cowardly then steps back).
- else by **Temperament**:
  - **Aggressive** — charge the nearest enemy it can reach; else advance at nearest.
  - **Ravenous** — charge the nearest figure of ANY side it can reach; else advance. *(All Mindless undead use this.)*
  - **Resolute** — on/next to its Focus → hold & strike adjacent; else advance to Focus.
  - **Cowardly** — engage only with the odds (2+ friends on the target); else keep distance, shoot, edge toward Focus at range.
  - **Protective** — move to the nearest wounded ally / leader; interpose / heal; strike only adjacent.
  - **Mindless** *(override)* — shamble the full move at the nearest **living** thing and hit it; never retreat, never test Nerve.

## Target priority
The one it can most likely **finish**: most-wounded in reach → nearest → flank/rear it can reach.

## Rout (Broken), by Temperament — B·10
Cowardly flees to edge · Resolute falls back to leader/Focus · Aggressive one last charge ·
Protective retreats to nearest ally · Ravenous turns **Wild** (attacks nearest, any side).

## Encounter budget (slots)
Party slots ≈ Champion 4 + ~6 per squad. Field enemies at **×1** (easy) / **×1.5** (fair) /
**×2** (hard). Each enemy's **SLOT** is on its card (chaff ½ · trooper 1 · elite 2 · brute 3–4).
A **Boss**'s slot value *is* the encounter (a slot-8 Boss ≈ a full party fight); pad with chaff.

*Enemy profiles + SLOT costs: `factions/data/faction_bestiary.json`, rendered as the
🧟 Bestiary tab on the Banner page.*
