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
- **Circle** — hero/avatar. **Faceless** (no facing — can't be flanked). Never tests
  Nerve, never breaks.
- **Square** — crew. **Has a facing.** May test Nerve, may break.

## Size = class  `[Definition]` — SIGNED (William, 2026-07-24)
**Three classes**, read from the **footprint**. No Monstrous; no Cavalry as a class.
```text
Small · Medium · Large
```
| Class | Square | Circle |
|---|---:|---:|
| Small | 20 mm | 25 mm |
| Medium | 25 mm | 32 mm |
| Large | 40 mm | 40 mm |

A "monstrous" creature is simply a **Large** figure, distinguished by its **traits**
(§14) — e.g. a plow-through-bodies trait — not by a fourth size.

## Elongated = mounted  `[Definition]`
**Mounted is geometry, not a size class.** An elongated base — an elongated Small,
Medium, or Large — communicates mounted geometry: **narrow frontage penetrates
deeply; wide frontage bulldozes broadly.** A mounted figure keeps its size class and
**plows as one class larger** (the lance, §4). There is **no** heavy/light cavalry
base split — cavalry doctrine emerges from Role · Tempo · Tool · Temperament ·
PACKETs · geometry, not a second size system.

## Tool set  `[Definition]` — SIGNED (William, 2026-07-24)
The Combat Module's Tool vocabulary — *how* a figure delivers Force — is a
**vibe-check** (ordinal classification, Law 10):
```text
Melee · Ranged · Hybrid
```
*Hybrid* = a figure that meaningfully delivers Force both in contact and at range.
Tool never sets purpose; a Melee figure may be Pressure, Anchor, or Utility.

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

Size gating across the three classes (Small · Medium · Large):
- larger bodies plow smaller; same-size plow grudgingly;
- **Small does not plow** — it slips through without an ordinary Disengage;
- **Mounted (elongated) plows as one class larger** (the lance);
- a head-on clearing tie is the **mover's choice**;
- movement continues until Agency/Move is exhausted or the mover jams.

*A figure that should shove through bodies unchecked (the old "Monstrous") carries a
**trait** (§14) — e.g. `unstoppable` (only a wall stops it) — rather than occupying a
fourth size class.*

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

> **SIGNED (William, 2026-07-24): Model 2 — Discrete.** Read the **single** Grade
> you reached and resolve **only** the Effects written on that line. A higher Grade
> does **not** carry up lower Grades' Effects. Authoring rule: write each Grade line
> as a complete result; if an Effect should appear at several Grades, print it on
> each. No accumulation, no "best-Wound-plus-every-passed-Effect."

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

**Discrete (Model 2):** the Greataxe above restates "2 Wounds" at Grade 3 on
purpose — you read **only** the reached line, so any Effect meant to carry up is
written on each line. Do **not** call this a Tier or a Ladder.

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

# 8 · Engagement & facing  `[Position]` — SIGNED (William, 2026-07-24)

**Bases touching = engaged.** No measured band — if two bases are in contact, the
figures are engaged, full stop. Engaging turns **Squares** to face each other;
**Circles are faceless** — a hero has no facing, so angle never matters to or from a
Circle.

A figure faces the enemy it is engaged with. Attacking a **free** figure pulls it
into engagement — it turns to face you and Counters (§9). A **Square already engaged
with another enemy** faces *that* foe, so a new attacker reaching its **flank or
rear** strikes an arc it isn't facing (a Flank/Backstab) and draws no Counter. A
**Circle**, being faceless, always Counters regardless of angle.

Leaving an engagement costs a **Disengage — 1 AP.**

**Reach is the exception to base-contact.** A Reach figure threatens a **1–2″ band**
and may strike a figure that tries to move past within that reach **without base
contact** — so you can't just walk by a spearman. A Reach strike from outside contact
is not engagement and draws **no Counter** (§9).

---

# 9 · Counter — turn and face  `[WAIT / PACKET]` — SIGNED (William, 2026-07-24)

Attack a figure and it **Counters** — one melee PACKET back — **and turns to face
you; you are now engaged.** A **free (unengaged) target always gets its swing** and
is pulled into engagement with its attacker: the first attacker on an open figure
eats the Counter. Structurally a Counter is a PACKET armed against the trigger
"struck by an enemy," so it lives in the WAIT family (deferred resolution) even when
it fires automatically.

The **only** ways to deny a Counter are positional:
- **Free target** → **Counters**, turns to face, becomes engaged with you. *(No, you
  can't safely walk up and stab a free figure — it turns and hits back.)*
- **Square already engaged with another enemy, struck on its unfaced flank/rear** →
  **no Counter.** It faces foe X; a new attacker reaching the arc it isn't facing gets
  the free side-shot. **Circles are faceless** → a Circle **always** Counters, from
  any angle.
- **Reach without contact** → **no Counter** (the reach striker is not glued).

**No cap, and the dying swing lands — SIGNED (William, 2026-07-24).** There is **no
per-round limit** on Counters and no `counter_x` economy: a figure Counters **every**
enemy that attacks it, and Counters **even as it dies.** Worked example — you attack a
figure, engage, it Counters and kills you; your body is shoved off; that same figure
is now free and will **Counter the next attacker** who steps up. *(A Counter is a
response, not an ATTACK, so it does not itself draw a Counter — otherwise two figures
loop forever. Flagged for confirmation, not yet William-signed.)*

---

# 10 · Nerve, morale & break  `[State / Temperament]`

**Morale track — SIGNED (William, 2026-07-24): three states** (like everything else,
in threes).
```text
Steady → Shaken → Broken
```
- **Squares test Nerve; Circles do not** — and Circles never break. `[Definition: shape]`
- A failed test steps a Square **down** the track (Steady → Shaken → Broken) `[State]`.
- **Broken = it Routs**, behaving by its **Temperament** (table below).
- **Rally** steps a figure back **up** the track (toward Steady).
- **Creature Type** may alter the branch.

**Temperament behaviour — SIGNED (William delegated → designed, 2026-07-24).** What a
figure does when **leaderless** (its AI fallback) and when it goes **Broken (Routs)**:

| Temperament | Leaderless — it… | On Broken (Rout) — it… |
|---|---|---|
| **Cowardly** | keeps distance, avoids danger, strikes only with the odds | flees to its own table edge |
| **Resolute** | holds or pursues the objective | falls back toward its leader / the objective (does not flee outright) |
| **Aggressive** | advances on the nearest enemy | one last reckless advance at the nearest enemy |
| **Protective** | guards / stays close to the nearest ally | retreats to the nearest ally |
| **Ravenous** | attacks the nearest figure, any side | turns **Wild** — attacks the nearest figure, friend or foe |

> **⚠ OPEN → E·nerve-trigger.** *What triggers a Nerve test* and *the pass/fail
> resolver* (how you roll it) are the **only** things still undecided here — William:
> "idk exactly what or how to trigger nerve tests yet, we'll figure it out."
> Everything else is signed: the three states, Broken = Rout-by-Temperament, and
> Rally. Just the **test trigger + resolver** remain open.

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

# 14 · Traits — referenced passive Definitions  `[Definition]` — SIGNED (William, 2026-07-24)

Always-true properties a figure carries — **Large, Flying, Mounted, Fearless,
Amphibious, Reach, Unstoppable, …** — are **Traits: referenced passive Definitions**
(Option B). A Trait is defined **once** and referenced by ID on a figure, exactly
like a PACKET but **passive** — it is never an ACTION/WAIT-resolved effect and never
holds runtime state (Law 5). The player-facing word is **trait**.
```json
{ "trait_id": "reach" }        { "trait_id": "unstoppable" }
```
A figure lists its `traits: [ ... ]`. Traits are **not** PACKETs (they resolve
nothing) and **not** size classes — `Large` is a size; `unstoppable` (plow through
bodies, only a wall stops it — §4) is a **trait** a Large figure may carry. **Reach**
is a Trait (and/or a PACKET property), no longer a Role.

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
