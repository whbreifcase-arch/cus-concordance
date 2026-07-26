# CUS — CONTINUOUS CLASH RESOLUTION
### v0.6 · canonical design principle · signed 2026-07-25

> Consolidated statement from William. This is the governing spec for how a
> "charge" / clash resolves. The focused sandbox that implements it lives in
> `factions/` (`CHARGE_LAB.html` + `sim/charge_sim.py`); see [[charge-sandbox]].

## Design Principle: Continuous Clash Resolution

A clash (often described as a "charge") is **not** a unique action or special mechanic.
It is an **emergent state** created when opposing groups commit to pushing into one
another while continuing to operate under the game's normal activation economy.

Nothing about the core mechanics changes during a clash. Models continue spending
activations, reactions, readiness, and other resources exactly as they normally would.
The clash is simply a **structured way to resolve many simultaneous interactions**
without overwhelming the players.

The intent is to model the **collision of two forces**, not a discrete "charge action."
Everything that happens during the clash is simply the normal game occurring under a
more structured resolution cadence.

## Preparation Matters

Because readiness and activations exist before contact, the battle is often decided
**before the lines actually meet**.

A player who exhausts every shield bearer before the clash may find those shields
unable to intercept attacks or protect the line. Likewise, players who preserve
readiness and reactions enter the engagement with greater tactical flexibility.

The collision is therefore the **culmination of earlier decisions**, not the beginning
of a separate combat phase.

## Continuous Resolution Mode

When opposing groups commit to a clash, the game temporarily enters a continuous
resolution mode.

Movement advances in small, consistent increments (typically **½″ or 1″**, depending
on what best fits the group's preferred pacing). These increments are **not turns, not
additional activations, and not simulation time**. They are pacing beats that organize
a complex engagement into understandable moments.

After each increment:

1. **Advance** all participating models.
2. **Resolve** every interaction that has become legal.
3. **Repeat** until movement is complete or the engagement naturally ends.

These pauses exist only to improve readability and decision-making. They are a
**presentation tool, not a new game mechanic**.

## Resolution Order

At each movement increment:

- The **attacking player declares** available attacks and intentions first.
- **Defenders declare and resolve** legal reactions.
- If those reactions generate new legal reactions for the attacker, those resolve
  immediately.
- Continue resolving reactions until **no further legal responses remain**.
- Resume movement to the next increment.

Nothing is artificially delayed. Interactions occur the **moment they become possible**:

- Entering weapon reach.
- Opportunity attacks.
- Shield interceptions.
- Protection abilities.
- Defensive reactions.
- Counterattacks.
- Any other triggered effect.

## Emergent Formations

Formations are **never activated as special modes**.

A shield wall, charge, breakthrough, escort, spear hedge, or collapsing line are simply
emergent battlefield states produced by: positioning · facing · remaining readiness ·
remaining activations · available reactions · player intent · timing.

Because every model continues using the same universal rules, formations may consist of
**any combination of units**. A breakthrough might contain shields, spearmen, swordsmen,
cavalry, or even a wizard. Players may surround a wizard with shields and drive the
formation through an enemy line — the shields naturally intercept attacks while creating
a temporary opening, letting the wizard emerge beyond the enemy formation. **No special
"escort" mechanic is required**; the behavior emerges entirely from the existing systems.

## Core Philosophy

The pauses during a clash are a **pacing mechanism, not a turn structure**.

The goal is not to simulate every instant of combat, but to transform a chaotic collision
into a sequence of **clear, cinematic decision points** that remain strategically deep
while letting players follow multiple simultaneous interactions.
