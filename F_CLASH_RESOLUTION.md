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
activations and resources exactly as they normally would, and answer with the same
free triggers they always had. The clash is simply a **structured way to resolve many
simultaneous interactions** without overwhelming the players.

The intent is to model the **collision of two forces**, not a discrete "charge action."
Everything that happens during the clash is simply the normal game occurring under a
more structured resolution cadence.

## Preparation Matters

Because position, facing and activations all exist before contact, the battle is often
decided **before the lines actually meet**.

> **Amended 2026-07-27 — the Reaction pool is struck (E · `reaction-struck`).** This
> section used to say that a player who exhausted his shield bearers' Reactions before
> the clash would find those shields unable to intercept. There is no pool to exhaust
> now. What survives is the stronger half of the same claim, and it is all positional:
>
> - a shield bearer who is **out of position** protects nobody — the 1″ is the rule;
> - a figure who has **already activated** holds no armed WAIT and cannot Brace into
>   the contact when it comes;
> - a line that arrives **facing the wrong way** concedes its flanks to everything
>   that reaches them, and facing is now what caps a Counter (B · 8).
>
> Preparation was never really about the pool. It was about arriving with your line
> pointed at the enemy and your feet under you.

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

> **Increments do not multiply triggers — SIGNED (William, 2026-07-27).** A Written
> Trigger fires **once per occurrence of the condition it names**, and *a movement is
> one occurrence.* A model crossing a spearman's reach band is **one** opportunity
> strike whether that crossing takes one increment or six. The increments are a
> reading aid (below); slicing a run finer must never buy anybody extra swings.
>
> This is the rule that replaced the Reaction pool as the brake, and inside a clash
> it is the load-bearing one. When in doubt, ask *"is this the same event, resolved
> more slowly?"* — if yes, it has already fired.

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
attacker's) carrying many responses inside it: the attacker declares, defenders choose
how to respond and whether to counter, cascades resolve — and the normal AP and
activation economy remains fully in force throughout. The clash is the container, not
an exception to the economy.

## Shields Eat Packets — either side

A shield-bearer may intercept a packet aimed at an **adjacent ally within 1″**, taking
the hit on its own armour. It **costs nothing**. This is a **universal response, not a
defender-only ability** — a shield escorting a charging model protects it exactly as a
shield in a standing line protects its neighbour.

**The cap is that he can die** (SIGNED, William 2026-07-25; restated 2026-07-27 with
the Reaction clause struck). Nothing else limits a shieldman: not a pool, not a
per-clash counter. He must be **within 1″**, he must **declare before the packet
resolves**, and **every intercept is a live hit on his own body** — armour rolled,
wounds landing on him.

> ⚠ **This is the change to watch.** Under the old pool, a shieldman intercepted
> roughly once per clash and the sim was tuned in that world. He can now hold as long
> as he can stand it. If it plays badly the fix is **1″ and facing**, not a new pool
> (B · 9b, ⚠ PROVISIONAL).

## Emergent Formations

Formations are **never activated as special modes**.

A shield wall, charge, breakthrough, escort, spear hedge, or collapsing line are simply
emergent battlefield states produced by: positioning · facing · remaining readiness ·
remaining activations · which packets are armed · player intent · timing.

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
