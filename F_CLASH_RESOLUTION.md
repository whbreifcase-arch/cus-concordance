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

1. **MOVE** all participating models (the Form Up body — B · 11).
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

## Earning the Charge-Push (the 3″)

**The 3″ is the sprint→charge transition threshold — SIGNED (William, 2026-07-25).**
A Sprint *becomes* a charge by covering **3″ of uninterrupted straight run-up into
contact**: a clean, unbroken run of at least 3″ ending in base contact with an enemy.
The clean run *is* the charge. Below 3″, the model simply arrives.

- It is a **threshold, not a distance budget.** It qualifies the contact; it does not
  cap what follows. The plow that follows resolves under the normal
  push→indent→crush geometry (B · 4) and runs until the mover's Move/Agency is spent
  or it jams.
- *(The 3″ penetration cap used in `CHARGE_LAB` / `clash_sim.py` is a **sandbox
  tuning parameter**, not this rule. Do not conflate the two.)*

**Interruption commits the charge where it happens.** "Interrupted" means **physical
contact** — a body gets in the way before the run is complete. When that happens, the
charge **commits at the point of contact**: the push begins *there*, against whatever was
hit, and the intended charge into the target beyond is **fumbled**. If ≥3″ of clean sprint
was already covered when the interrupting body was struck, that contact is itself a valid
charge *into the interrupter* (it gets the push); if less, the model simply halts there.
Either way the intended charge is spent on the wrong target.

> This is exactly why a **screen** defeats a charge: the chargers commit on the chaff,
> spend their push there, and arrive at the real line already spent. Deny an enemy a clean
> 3″ lane — with terrain, spacing, or a screen — and you deny them the charge itself,
> before a blow is struck.

**A reaction is not an interruption.** A shot, a reach-strike, or any triggered effect that
fires *while the model is moving* simply **resolves** — it does not fumble the sprint.
Getting hit on the way in ≠ getting stopped. Only physical contact interrupts.

**It is still one activation.** The entire sprint-charge is a single activation (the
attacker's) carrying many reactions inside it: the attacker declares, defenders choose how
to respond and whether to counter, cascades resolve — and all normal AP, activation, and
reaction budgets remain fully in force throughout. The clash is the container, not an
exception to the economy.

## Shields Eat Packets — a reaction, either side

A shield-bearer may spend **1 Reaction** to intercept a packet aimed at an **adjacent
ally within 1″**, taking the hit on its own armour. This is a **universal reaction, not a
defender-only ability** — a shield escorting a charging model protects it exactly as a
shield in a standing line protects its neighbour.

**The Reaction pool is the only cap** (SIGNED, William 2026-07-25; A · IV, B · 12):
`1 per figure · 2 for a Circle`, refreshed at the start of that figure's **own
activation**. A spent shield can't intercept again until it activates. There is no
separate per-clash intercept limiter — nothing caps a shieldman except that he
**spent his Reaction** and that he **can die eating the hit.** In a clash resolved
inside a single activation, that reads as "one per model per clash" in practice,
which is why the sim behaves the way it does.

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
