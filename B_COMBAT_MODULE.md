# CUS — THE COMBAT MODULE
### v0.6 · the reference implementation · rebuilt 2026-07-23

> **What this is.** The Kernel (Document A) doing real work: physical conflict.
> Combat is the *reference* implementation — it exercises the most primitives —
> but it is **not** the Kernel's master (Law 12). Everything here is a **Combat
> Module fact** and may be retuned; none of it is promoted to Kernel law.
>
> **Citation rule.** Every mechanic names the Kernel primitive it reads or
> writes, in brackets: `[Position]`, `[PACKET→Grade]`, `[Agency]`, `[State]`.
> If a mechanic can't cite one, it doesn't belong here (Law 14).
>
> **Translation.** Combat renames the three verbs:
> `MOVE→Advance · ACTION→Strike/Interact/Cast · WAIT→Brace/Overwatch`. The player
> reads the flavour; the system reads MOVE · ACTION · WAIT.

---

# 1 · Bases — physical information

The base *is* the label. Pick up the model and read it.

## Shape = type  `[Definition]`
```text
Circle = hero / avatar          Square = crew / commandable body
```
- **Circle** — never tests Nerve, never breaks.
- **Square** — may test Nerve, may break.

## Size = class  `[Definition]`
Class is read from the **footprint**, not a hidden keyword.
```text
Small · Normal · Mounted · Large · Monstrous
```
| Class | Square | Circle |
|---|---:|---:|
| Small | 20 mm | 25 mm |
| Normal | 25 mm | 32 mm |
| Mounted | 20 × 40 mm | oval |
| Large | 40 mm | 40 mm |
| Monstrous | 50 mm | 50 mm / large oval |

*(Exact round & oval standards are `⚠ OPEN → E·base-millimetres`; the vocabulary
is sound, the millimetres provisional.)*

## Elongated = mounted  `[Definition]`
An elongated base communicates mounted geometry: **narrow frontage penetrates
deeply; wide frontage bulldozes broadly.** There is **no** hidden heavy/light
cavalry base split — cavalry doctrine emerges from **Role · Tempo · Tool ·
Temperament · PACKETs · geometry**, not a second size system.

---

# 2 · Movement  `[writes Position]`

Advance is combat's MOVE: choose a legal destination or trajectory, pay Agency,
change Position. Movement carries the usual domain aliases (Advance, Sprint,
Leap, Withdraw) — all MOVE.

- **Obstacles are paid inline** as part of one continuous MOVE (no
  stop-spend-move). Climbing/vaulting costs extra Agency per story `[Agency]`.
- Dropping one story is free and harmless; dropping further, or being displaced
  off an edge, is resolved by the owning procedure `⚠ OPEN → E·combat-aftermath`.

---

# 3 · Sprint & Impact  `[writes Position]`

**Charge is retired as a keyword** — it collided with movement. Instead:
```text
Sprint = continued MOVE
Impact = the contact that MOVE creates
```
> **When a Sprint contacts another body, resolve an Impact.**

The figure stays in its Sprint; **Impact** names the collision and its
resolution, not the movement producing it. "Charge" survives only as flavour.

Conceptual reduction:
```text
Sprint through bodies  =  MOVE  +  N× Impact resolutions  +  Position changes
```

---

# 4 · The Push — geometry, not a number  `[writes Position]`

Two bases cannot share space. A moving base continues along its **straight
trajectory** and displaces contacted bases the **minimum** needed to clear its
path. Slide the models; don't measure. The cascade:

1. **Push** — shove the contacted body aside enough to clear the lane.
2. **Indent** — if bodies behind it block the sideways shove, carry them forward;
   the line dents.
3. **Crush** — if a **wall or obstacle** prevents clearance, the mover **jams and
   stops**, and the Impact receives the appropriate bonus (nowhere to go = it
   crushes).

**Displacement is not damage.** The Push changes **Position**; any Wound or state
change comes from the **PACKET** the Impact resolves `[PACKET→Grade]`. The
wall-crush is the only place a blocked shove feeds the hit.

Geometry to preserve for testing (Combat facts, not Kernel law):
- larger bodies plow smaller; same-size plow grudgingly;
- **Small does not plow** — it slips through without an ordinary Disengage;
- **Mounted** plows as one class larger (the lance);
- **Monstrous** is stopped by **walls, not bodies**;
- a head-on clearing tie is the **mover's choice**;
- movement continues until Agency/Move is exhausted or the mover jams.

---

# 5 · PACKET resolution in combat  `[resolves PACKET → Grade]`

A combat PACKET may define: `dice · success_number · range/reach · area · cost ·
grades · effects`. It is **referenced, never copied** onto each weapon; the
ordering below is written **once, here**, not on every card.

Typical flow:
```text
declare target        [Position: legality]
→ verify legality
→ load modifiers      (position/facing/environment — prefer Position over numbers)
→ roll dice
→ count Successes     (each die ≥ success_number)
→ determine Grade     (highest Grade reached)
→ resolve Effects
→ roll Armour per Wound
→ apply surviving Wounds        [State]
→ resolve Counter / Nerve / aftermath   (owned procedures — §9, §10)
```

> **⚠ OPEN → E·grade-accumulation.** Whether resolving Grade *N* also resolves
> every lower Grade's Effects, or **only** the Effects written at Grade *N*, is an
> **unresolved owner call.** The Combat Module will not roll dice against a
> guessed rule — Document E states both models. Until it is signed, resolve a
> PACKET by reading its written Grade explicitly and, where a PACKET is ambiguous,
> pause for the table's agreement.

---

# 6 · Success Grades in combat

The result structure is the Kernel's **Success Grade** (Document A · VI). A combat
PACKET lists its Grades against a success count:
```text
GREATAXE — Dice 3 · Success 5+
  GRADE 1 — 1 Wound
  GRADE 2 — 2 Wounds
  GRADE 3 — 2 Wounds + Cleave
```
- **Success** — a die ≥ the PACKET's success number.
- **Grade** — how well the roll succeeded.
- **Effect** — Wound, Push, Knockdown, Guard, Cleave, Execute, ignore-Armour, …
  the state change a Grade resolves `[State]`.

Do **not** call this a Tier or a Ladder.

---

# 7 · Wounds & Armour  `[State]`

Health track (Combat fact, retunable):
```text
Fine → Hurt → Knocked Out → Dead
```
Armour rolls **one save die per incoming Wound**. Current spectrum (Combat facts,
**not** Kernel primitives — do not promote these numbers upward):
```text
None —      Light 6+      Medium 5+      Heavy 4+
```
A save that would worsen past 6+ can no longer save. Unsaved Wounds apply to the
health track.

---

# 8 · Engagement  `[Position]`

Engagement is a **Position** relationship: moving within the engagement band of
an enemy makes you sticky. Leaving costs a **Disengage** (an Agency spend and/or a
free swing granted to each engager, per the owned procedure). A wall of bodies is
several engagements to break. Reach threatens its band without gluing — it holds
differently. *(Exact bands and the Disengage penalty are Combat facts; the
break-away swing is part of `⚠ OPEN → E·combat-aftermath`.)*

---

# 9 · Counter — a WAIT-shaped aftermath  `[WAIT / PACKET]`

A figure struck in melee may resolve a **Counter** — one melee PACKET back at its
attacker. Structurally a Counter is a **PACKET armed against the trigger "I was
struck in contact"** — it lives in the WAIT family (deferred resolution), even
when it fires automatically. Reach (no contact) and Backstab (rear/unaware)
suppress it.

> **⚠ OPEN → E·combat-aftermath.** The exact Counter economy — once per round vs.
> Counter X, whether a killed figure still swings, what suppresses it, and how it
> interacts with ganging — must be reconciled from contradictory drafts before it
> is signed. Not copied blindly.

---

# 10 · Nerve & break behaviour  `[State / Temperament]`

Structure carried forward (procedure **not** finalized):
- **Squares test Nerve; Circles do not.** `[Definition: shape]`
- A failed test degrades or breaks the agent `[State]`.
- **Temperament** biases how a broken or leaderless agent behaves `[Temperament]`
  — rebuilt around *preferred application of Force*, not as an AI script.
- **Rally** restores command or stability.
- **Creature Type** may alter the break branch.

> **⚠ OPEN → E·combat-aftermath.** The exact **Shaken · Rout · Squelch · Wild ·
> Rally** procedures and the Creature-Type branches are unresolved and
> contradictory across archived drafts. This module does **not** copy one in.
> Temperament's controlled list is also `⚠ OPEN → E·temperament-vocabulary`.

---

# 11 · Formations — descriptive, not prescriptive  `[Position]`

> **Formations are descriptive, not prescriptive.** Players maintain the declared
> shape as closely as practical given Position, terrain, and contact.

A Formation Definition holds only: `Name · Picture · one sentence of intent`.
- **Advance** *translates* a shape (moves the group along a route).
- **Reform** *changes* a shape.

Both reduce to **existing verbs and Position changes** — they are **not** new
Kernel verbs (Law 11). Avoid rigid spacing matrices or transformation maths unless
playtesting proves the precision buys a better decision (Law 8).

---

# 12 · Alternation — attention management  `[Agency]`

Combat's current activation model:
```text
Side A activates one Figure → Side B activates one Figure → repeat until exhausted.
```
If one side runs out of eligible Figures, the other resolves its remainder one at
a time. Wild/uncontrolled figures resolve afterward per the owning procedure.
Alternation is **attention management** — a camera that directs focus to the
hottest fight — not mere initiative bookkeeping.

---

# 13 · Creature Type in combat  `[Definition]`

```text
Man · Beast · Spirit · Construct
```
Creature Type governs combat's **morale, mending, and targeting** relationships
(e.g. who tests Nerve, who can be healed, who never breaks). Its exact branches
are bound up with `⚠ OPEN → E·combat-aftermath`. Creature Type is **what a figure
is**; its **Archetype** (Knight, Berserker, Assassin…) is *who* it is — a readable
`Role + Tool + signature` combination, never confused with type.

---

# 14 · Persistent traits — location undecided  `[Definition?]`

Always-true properties a combat figure may carry — **Large, Flying, Mounted,
Fearless, Amphibious, Reach** — are real, but **where they live is unresolved**:
Figure Definition attributes, referenced passive Definitions, PACKET-adjacent
metadata, or a distinct capability layer.

> **⚠ OPEN → E·persistent-traits.** Do **not** force these into PACKET merely
> because PACKET exists. The Combat Module treats them as Definition-level truths
> pending the ruling; **Reach** in particular is a PACKET property or trait, no
> longer a Role.

---

# 15 · Combat presentation  `[Presentation]`

What the player sees is translation, never a parallel mechanic:
```text
player:  Advance · [weapon] "Spear Thrust" · GRADE 1/2/3 · Brace
system:  MOVE   · ACTION packet_id:spear_thrust · Grade · WAIT (armed packet)
```
Floating table state shows **Instance** only (Position, Wounds, Agency left,
conditions, an armed WAIT) — never the Definition's fixed stats, which live on the
card.

---

# 16 · What this module owes the Kernel

Every section above either writes **Position**, resolves a **PACKET** into a
**Grade**, spends **Agency**, changes **State**, or reads a **Definition** axis
(Role · Tempo · Tool · Temperament · Creature Type). Nothing here invents a
parallel universal action, and nothing stores runtime state in a Definition or a
PACKET (Laws 5, 11, 14). The unresolved combat calls are collected — unanswered —
in **[Document E](E_OPEN_DECISIONS.md)**.
