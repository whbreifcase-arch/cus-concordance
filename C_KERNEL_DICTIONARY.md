# CUS — THE KERNEL DICTIONARY
### v0.6 · one canonical definition per term · 2026-07-23

> The Rosetta Stone. Every module checks its words here. If a word isn't in this
> Dictionary, either add an alias to an existing entry or the word is inventing a
> mechanic (forbidden, Law 11). Entries note the **owner** and what the term
> **reads / writes / consumes / creates.**
>
> **On "not."** Entries define; they don't argue. Where a word is commonly
> mistaken for a neighbour you'll see `→ G·<slug>` — the reasoning lives in
> **[Document G · Why Not](G_WHY_NOT.md)**. Where a word is *retired*, the
> forwarding address is **[Document D](D_MIGRATION_MAP.md)**.

---

## Substrates

### Position
Where an entity stands relative to other entities, objects, boundaries,
opportunities, and threats. The shared substrate of the board or situation.
**Owner:** Kernel. **Written by:** MOVE (and Impact). **Read by:** almost every
procedure. The Kernel's first source of tactical depth.

### Force
An agent's capacity to produce, resist, or alter consequential change — broader
than damage (violence, protection, healing, command, influence, supply, …).
**A formal Kernel primitive** (SIGNED, William 2026-07-24), alongside Position,
State, and Resource — but **non-numerical**: there is no Force stat. An agent's
relationship to Force is read on four axes (Role, Tempo, Tool, Temperament) and
expressed by writing State, Position, or a Resource. **Owner:** Kernel.

---

## Resources

### Agency
The limited capacity an entity has to act during **its own** activation; carried as
**AP**. Unless a module says otherwise, **1 AP buys one MOVE, one ACTION, or one
WAIT.** **Owner:** Kernel. **Consumed by:** the three verbs. One of the exchangeable
Resources. `→ G·agency-is-not-autonomy`

### Reaction
The limited capacity an entity has to act during **someone else's** activation
(SIGNED, William 2026-07-25). A second Resource, budgeted and spent exactly like
Agency and **never paid out of AP**. **Every triggered PACKET costs 1 Reaction** —
Counter, shield intercept, reach strike, or a firing Overwatch. When the pool is
empty the figure cannot respond, however many triggers fire: Reaction *is* the cap,
which is why the Kernel needs no `counter_x` limiter. **Owner:** Kernel; the module
sets the budget. **Combat's budget:** `1 per figure · 2 for a Circle`, refreshed at
the start of the figure's own activation (B · 12).

### Resource
Any limited quantity spent to produce change: `Agency · Reaction · Health ·
Morale · Information · Influence · Supply · Time`. **Owner:** Kernel; each module
implements the resources it needs. `→ G·position-is-not-a-resource`

---

## The three verbs

### MOVE
The verb that **changes Position now**. Acts on the acting entity; writes directly
to Position. **Owner:** Kernel. **Consumes:** Agency. **Creates:** a Position
change. **Aliases:** Sprint · Leap · Teleport · Withdraw · Sail · Approach — these
name *kinds* of MOVE. **Combat does not rename MOVE** (SIGNED William 2026-07-25;
the old *Advance* alias is retired — see [Document D](D_MIGRATION_MAP.md)).

### Invocation
**How a PACKET reaches the resolver.** Broader than *verb*: the player has three
verbs, the engine has five invocations (SIGNED William 2026-07-25, A · XIV).
```text
MOVE | ACTION | WAIT | WRITTEN_TRIGGER | OWNED_PROCEDURE
```
The first three are chosen by a player and paid in **Agency**; `WRITTEN_TRIGGER` is
paid in **Reaction**; `OWNED_PROCEDURE` (Impact, Nerve, a fall, aftermath) is paid
by whatever the procedure says. **Owner:** Kernel.
`→ G·three-verbs-is-not-three-invocations`

### ACTION
The verb that **resolves a PACKET now** against a valid target. **Owner:** Kernel.
**Consumes:** Agency. **Creates:** the PACKET's Effects (via a Grade). **Aliases:**
Strike · Attack · Use · Cast · Heal · Repair · Persuade · Accuse · Interact · Hack.
*(Uppercase ACTION = this verb; lowercase "action" = any AP spend in prose.)*

### WAIT
The verb that **arms a PACKET against a trigger**, deferring its resolution.
**Owner:** Kernel. **Consumes:** Agency to arm it, then **Reaction to resolve it.**
**Creates:** a primed `trigger → resolution`. **Aliases:** Brace · Overwatch ·
Prepare Response · Wait.

> **WAIT vs. Written Trigger.** A WAIT is armed by a player who spent AP; a
> **Written Trigger** is a clause inside a PACKET that fires on its own condition,
> no AP and no arming. **Both spend Reaction** (A · III, SIGNED William
> 2026-07-25). An armed WAIT on a figure with no Reaction left does not resolve.
> `→ G·wait-is-not-a-written-trigger`

### Written Trigger
A trigger clause authored **into a PACKET** — `{ "trigger": { "on": …, "cost":
"1 Reaction" } }` — that fires when its condition occurs, without AP and without
being armed. **Owner:** the PACKET that carries it. **Consumes:** Reaction. If a
figure's weapons and conditions carry no such clause, it simply does not respond.

---

## The executable definition

### PACKET
A stateless, named, referenced definition of a resolvable effect — the single
universal executable object (weapon, spell, ability, interaction, reaction,
impact, heal, command). **Owner:** the module that resolves it. **Holds no runtime
state.** Has a **neutral ID** + a player-facing **name**. Resolved by ACTION, armed
by WAIT, or invoked by another owned procedure. Carries no good/bad tag.

### Success
A single die that meets a PACKET's success number. **Owner:** the resolving
Procedure. Counted to determine the Grade.

### Grade  *(Success Grade)*
How well a PACKET succeeded — the highest Grade reached by the Success count.
**Owner:** the resolving Procedure. Replaces Ladder/Tiers/Rungs
([Document D](D_MIGRATION_MAP.md)). **Discrete (Model 2, SIGNED William
2026-07-24):** resolving Grade *N* resolves **only** the Effects written on Grade
*N* — no inheritance. `→ G·grade-is-not-a-tier`

### Effect
The state change a resolved Grade produces (Wound, **Shove**, Knockdown, Guard,
Cleave, Execute, Terror, heal, reveal, …). **Owner:** the PACKET (defined) / the
Procedure (applied). **Writes:** State (or Position, for displacement Effects).
*(The displacement Effect is **Shove**. "Push" now names only the charge plow,
B · 4.)*

### Trait
An **always-true** property a Figure carries — a **referenced passive Definition**
(SIGNED William 2026-07-24; keyword **trait**). Defined once, referenced by ID
(`{ "trait_id": "reach" }`), like a PACKET but **passive**: it resolves nothing and
holds no runtime state. Examples: Flying, Fearless, Amphibious, Reach, Shield,
Unstoppable. A Trait resolves nothing. **Owner:** the module that defines it.

> **Base properties live in `base`** (Law 1 — one owner): `size_class`
> (Small · Medium · Large) and `mounted`. A "monstrous" figure is a Large base
> carrying `unstoppable`. `→ G·traits-are-not-base-properties`

---

## The four axes

### Role
An agent's **primary relationship with Force**. **Owner:** Kernel. Exactly three:
**Pressure · Anchor · Utility.** `→ G·role-is-not-a-job-list`

### Pressure
The Role that **applies Force** — threatens, breaches, displaces, suppresses,
pursues, exposes, overwhelms.

### Anchor
The Role that **prevents Force** — holds, blocks, absorbs, protects, delays,
intercepts, preserves.

### Utility
The Role that **changes Force** — amplifies, weakens, redirects, restores,
reveals, coordinates, relocates, transforms. Absorbs older Control + Support.

### Tempo
**The time it takes to apply Force relative to its peers.** Ordinal:
`> Slow · >> Normal · >>> Fast`. A designer-assigned **classification** (Law 10),
**read by humans and never by the resolver** — no procedure consumes it.
`→ G·tempo-is-not-speed` · `→ G·not-every-axis-needs-teeth`

### Tool
**How Force is delivered** — the channel or mechanism through which an agent
expresses its Role. Does not define purpose; the same Tool may deliver any Role.
**Owner:** Kernel defines it abstractly; each module declares its own controlled
Tool vocabulary. **Combat's set (SIGNED William 2026-07-24): `Melee · Ranged ·
Hybrid`** — a vibe-check classification (like Tempo), *Hybrid* = delivers Force both
in contact and at range. Old `Utility` is a Role, not a Tool.

### Temperament
The agent's **preferred application of Force** — behavioural bias when several
legal applications exist (when to commit, where to direct Force, what to do when
cohesion fails). Preference, not capability. **SIGNED (William 2026-07-24):**
`Cowardly · Resolute · Aggressive · Protective · Ravenous`. Their leaderless and
break/Rout behaviours are the combat table in **B · 10**.

---

## Identity

### Creature Type
**What an entity is** — governs broad biological/morale/repair/targeting
relationships owned by a module. Combat set: `Man · Beast · Spirit · Construct`.

### Archetype
**Who an entity is** in play language: `(Role + Tool + signature) → Archetype`
(Gunslinger, Berserker, Knight, Scout, Artillery). A readable combination. Old role
words (Skirmisher, Tank, Sniper, Support) live here.
`→ G·archetype-is-not-a-primitive`

---

## The four layers

### Definition
Static, referenced information describing **what a thing inherently is** (figure
profile, PACKET, Formation, Mission template, Role, Tool, Tempo, Temperament).
**Holds no runtime state** (Law 5).

### Procedure
The **owned resolution method** that turns a grammar statement into an outcome
(movement, PACKET, Grade, Impact, Nerve, travel, social resolution). A module owns
its procedures.

### Instance
**What is true right now** (current Position, remaining Wounds, conditions, an
armed WAIT, active Mission, current supplies, relationships). The **only** home of
runtime state.

### Presentation
**What the player sees** — flavour verbs, symbols, cards, models, markers. It
**translates** the Kernel and never forks a parallel mechanic.

---

## Organizational hierarchy

### Figure
One independent agent / one piece. Owns capability: `Role · Tempo · Tool ·
Temperament · signature · PACKET references · stats`. Remains a complete agent
inside any higher formation.

### Fireteam
The primary local maneuver element: a **Sergeant + ~3–5 Retinue.** The Sergeant
supplies coordination, Rally, formation handling, command continuity.

### Banner
The warband / persistent tactical group: a **Champion + Fireteams + loose
specialists.** `→ G·banner-is-not-a-command-state`

### Caravan
The **persistent expedition** — the body of people, beasts, wagons and materiel
that travels between events, and the **physical representation of the persistence
axis** (a real model, read like a base). An **entity**, not a module: what persists
and how it changes is owned by **Persistence** (Document H). **Owner:** Kernel
(as a hierarchy layer, A · X).

### Army
Many Banners coordinated for a military campaign.

### Kingdom
The political society containing institutions, law, Caravans, and Armies.

---

## Command & targeting

### Mission
Constrained intent for an **AI-controlled** Banner: `Intent · Priorities · Focus ·
Constraints · Fireteam assignments`. Narrows the decision problem; does not
puppeteer Figures. **AI-only** (Law 9).

### Target
What an ACTION or WAIT resolves against: **Self · Agent · Object · Point · Area**
· or a **Trigger window** (WAIT). Legality is owned by the resolving module.

### Area
The shape an Effect covers: none · a radius · a template. A property of the
grammar statement, resolved by the PACKET.

### State
What is true of an Instance right now and can change: `wounds_remaining`,
Reaction remaining, conditions, morale, an armed WAIT, activation flags.
**Written by** Effects and Procedures; **stored** in the Instance.

---

## Combat-specific movement terms

### Sprint
A **continued MOVE** — combat's word for pressing movement forward. Writes
Position. When a Sprint contacts a body, it produces an **Impact**.

### Impact
The **contact a MOVE creates**, and its resolution. Names the collision, not the
movement. Displaces bodies via the Push `[Position]` and may invoke a PACKET for
any Wound/state change `[PACKET→Grade]`. A Combat Module procedure. Replaces the
retired keyword **Charge**.

### Charge
The **name for a Sprint that earned it.** A Sprint becomes a charge when it covers
**3″ of uninterrupted straight run-up into contact** (SIGNED, William 2026-07-25;
B · 3). Only *physical contact* interrupts; a shot or reach-strike taken on the way
in resolves without stopping the run. A **threshold, not a distance budget.**
Governing spec: **Document F**. `→ G·charge-is-not-an-action`

### Push
The **charge plow** — the §4 geometry by which a moving base displaces contacted
bases along its trajectory: `Push → Indent → Crush`. **Writes:** Position.
**Owner:** Combat. *(Not the weapon Effect — that is **Shove**.)*

---

## Combat reactions

### Counter
One melee PACKET returned by a figure struck **in melee base contact.** A
**Written Trigger** carried by the weapon or condition — **not a WAIT**, since no
AP was spent arming it (SIGNED, William 2026-07-25). **Consumes:** 1 Reaction.
**Universal in practice** — every figure carries **Fists**, so every figure always
has a legal Counter; the only thing that stops one is an empty Reaction pool. No
artificial cap: a figure Counters every attacker and even as it dies. A Counter does
not itself draw a Counter. Ranged never draws one. If both the ACTION and the
Counter are lethal, **both figures die.** **Owner:** Combat (B · 9).

### Fists
**Standard equipment on every figure** (SIGNED William 2026-07-25). A weak melee
PACKET, never printed on a card, never bought, never lost, always legal in base
contact — and it carries the **Counter** trigger like any other weapon. Fists are
why "strike a figure in contact and it Counters" holds without exception, and why a
spearman in contact (§8) or a caster out of mana is downgraded rather than helpless.
**Owner:** Combat (B · 5). `→ G·support-units-are-not-defenceless`

### not_in_contact
A **packet constraint**: this PACKET cannot be resolved while the bases are touching
(SIGNED William 2026-07-25). Carried **by definition** by Reach packets and **by
default** by ranged packets; a ranged packet that omits it (wrist crossbow, hand
flamer, point-blank spell) is claiming a real, priced advantage. Reusable by any
packet. **Owner:** Combat (B · 5, B · 8).

### Reach
A **trait and/or packet property**: strikes out to a stated **X″** but carries
`not_in_contact` — so it works on a figure moving past and is illegal once bases
touch. A Reach strike from outside contact **creates no engagement and draws no
Counter**, and costs **1 Reaction** when it fires on someone else's activation.
**Owner:** Combat (B · 8). `→ G·reach-is-not-a-role`

### Form Up
The **Sergeant's group-MOVE procedure** (SIGNED William 2026-07-25). The Sergeant
names unactivated friendlies **within 4″**, places them in a shape, and every
participant spends **1 AP** and is **marked activated**; they then MOVE as one body,
declaring all strikes and Shoves **before contact**. The 1 AP covers the MOVE, the
attacks and the Shoves — **but never the Reaction pool**, which stays intact.
A figure may only strike what **its own base moves into** (Reach excepted).
**Circles cannot call or join one.** **Owner:** Combat (B · 11).
`→ G·form-up-is-not-free`

### Shield Intercept
A Written Trigger on the **Shield** trait: spend **1 Reaction** to consume an
ACTION packet aimed at a friendly within 1″ and take the hit on your own Armour.
Declared before the packet resolves; works regardless of facing; eats melee and
ranged alike; draws no Counter. **Uncapped by design** — the limits are that he
spent his Reaction and that he can die eating it (SIGNED, William 2026-07-25).
**Owner:** Combat (B · 9b).

### Brace
A **WAIT**, Square only: 1 AP, ends the activation, lasts until the next one.
Locks facing; **+1 die** into the front arc and **−1 die** for enemies attacking
it; concedes flank and rear entirely. **Grants no Reaction** (SIGNED, William
2026-07-25) — it buys hard bonuses and step-ups, never extra availability. Broken
by a Shove. Circles cannot Brace. **Owner:** Combat (B · 9b).

### Overwatch
A **WAIT**: spend **1 AP** to arm a chosen PACKET against a declared trigger —
buying a *better* response than your Written Triggers would give. **Still spends
1 Reaction when it fires** (SIGNED, William 2026-07-25); with an empty pool it does
not resolve. **Owner:** Combat (B · 9b).

### Shove
The weapon displacement **Effect** (renamed from "Push"): move the target directly
away, up to X″, ending no more than Y″ away — default X = Y = 1″, tunable per
effect. **Breaks a Brace** rather than merely nudging it. **Writes:** Position.
**Owner:** Combat (B · 9b).

---

## Health

### Wounds
**A number, not a track** (SIGNED, William 2026-07-25). How much punishment a
figure absorbs before it goes down; **1 or 2 is standard** and it is a tunable
knob. Definition: `Wounds`. Instance: `wounds_remaining`. Each unsaved Wound
subtracts 1. Where the old `Fine → Hurt → KO → Dead` track went:
[Document D](D_MIGRATION_MAP.md). `→ G·wounds-are-not-a-track` **Owner:** Combat.

### Knocked Out · Dead
The two genuine **States** a figure enters at `wounds_remaining = 0`. Which one is
decided by the Effect that felled it and its Creature Type (B · 7, B · 13). They
change what a figure *can do*. **A Knocked Out figure that is hit is killed and
rolls no Armour** (SIGNED William 2026-07-25) — armour protects the standing only.
A downed body still occupies its base and participates in the Push cascade.
`→ G·wounds-are-not-a-track` **Owner:** Combat.
