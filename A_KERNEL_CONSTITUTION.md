# CUS — THE KERNEL CONSTITUTION
### v0.6 · the universal grammar · rebuilt 2026-07-23 · **Reaction struck 2026-07-27**

> **What this is.** The bones. The universal architecture every module obeys —
> and nothing else. It holds the substrates, the three verbs, the four axes, the
> PACKET, the ownership laws, and the module contract. It does **not** hold
> weapon numbers, armour saves, base millimetres, or the Push. Those are Combat
> Module facts (Document B), not Kernel law.
>
> **Authority.** This document and its siblings (A–E) supersede every older CUS
> document. When they conflict, this wins.
>
> **On gaps.** Where a genuine question is unresolved it is marked
> `⚠ OPEN → E·<topic>` and left open. A blank is never filled for convenience.
> **No constitutional question is currently open.** A rule marked
> **⚠ PROVISIONAL** is a *signed* rule awaiting ratification in play — in force
> now, not a gap. See [Document E · Decision Register](E_OPEN_DECISIONS.md).
>
> **On "not."** This document states rules; it does not argue for them. Where the
> obvious reading of a rule is wrong, you'll see a token — `→ G·<slug>` — and the
> reasoning lives in **[Document G · Why Not](G_WHY_NOT.md)**. Read it once.

```text
REALITY  →  GRAMMAR  →  CAMPAIGN  →  CONFLICT  →  MECHANICS
 (what is)  (rules of   (what       (how it is   (the owned
            order)      persists)    contested)   procedures)
```

---

# I · What CUS is

**CUS is a deterministic ludic Kernel: a universal grammar for organized action,
persistent state, and conflict across many scales.**

Combat is its **reference implementation, not its definition.** The Kernel must
carry physical conflict, social conflict, politics, logistics, travel, trade,
construction, crafting, and exploration as **peers** — never as species of war.

Higher scales **compose** lower scales; they never replace them. A duel and a
kingdom obey the same grammar, so nothing is re-learned as the game grows.

> **One grammar, many domains, different owned procedures.**

---

# II · The primitives — Position · State · Resource · Force

The Kernel has exactly **four primitives.** Two of them — **Position** and
**Force** — are the *substrates*: everything the Kernel reads or writes
ultimately touches one of them. The other two — **State** and **Resource** — are
how a substrate is *stored* and *spent*.

```text
SUBSTRATES   Position — where things are
             Force    — capacity to produce, resist, or alter change
CARRIERS     State    — what is currently true (stored in an Instance)
             Resource — a limited quantity that can be spent
```

Position is a substrate, not a Resource — you change it, you do not spend it.
`→ G·position-is-not-a-resource`

The two sections below define the substrates.

## Position
**Position is where an entity stands relative to other entities, objects,
boundaries, opportunities, and threats.** It is the shared substrate of the
board or the situation. **MOVE writes Position directly.**

Depth comes first from Position — geometry, timing, facing, relationship —
**not** from stacks of numerical modifiers. If a design can create a decision
through Position instead of a number, it should.

## Force
**Force is an agent's capacity to produce, resist, or alter consequential
change.** Force is broader than damage. In physical conflict it wears the masks
of violence, protection, displacement, healing, command, suppression,
information, mobility, and shaping. In another module it is influence, trust,
authority, supply, argument, negotiation, labour, or institutional power.

An agent is read through **four independent relationships with Force:**

```text
ROLE · TEMPO · TOOL · TEMPERAMENT
```

**SIGNED (William, 2026-07-24): Force is a formal Kernel primitive** — one of the
four, alongside Position, State, and Resource. It remains
**non-numerical**: there is no Force stat. An agent's Force is *read* through the
four axes (Role · Tempo · Tool · Temperament) and *expressed* by writing State,
Position, or a Resource. `→ G·force-is-not-a-stat`

## The three channels of harm — Body · Mind · Soul — SIGNED (William, 2026-07-28)
An agent takes consequential change through **three channels.** Each channel is a
State track with its own **save** and its own three-state terminal. They are
independent — a figure's toughness in one says nothing about another.

```text
CHANNEL   what it is        SAVE                        TRACK (terminal states)
BODY      the flesh         Armour (None/L6+/M5+/H4+)   upright → Knocked Out → Dead
MIND      the will          Nerve  (None/L6+/M5+/H4+)   Steady  → Shaken     → Broken
SOUL      —                 —                           —
```

- **Body and Mind are symmetric.** An attack deals **Wounds** (Body) or **Morale**
  (Mind) as grade-line effects; the matching save resists each, and each unsaved
  point steps that channel's track. **Nerve is psychic armour** — the same tiered
  save as Armour, applied to the Mind (Combat: B·10). Fear is not a special
  procedure; it is damage on a channel. `→ G·morale-is-a-channel`
- **A figure can be strong in one channel and glass in the other** — a heavy knight
  of Light Nerve, a barefoot fanatic of Heavy Nerve. The mismatches are the
  interesting units.

### SOUL — ⚠ RESERVED, PERMANENTLY ⚠
> **SOUL** — a formal, undefined Kernel primitive. Permanently non-numerical and
> non-defined. It is never named in a rule, never called, never triggered, never
> read, and its state is never changed.
> **Do not define, invoke, or alter it under any circumstances. Ever.**
> *Signed by the original author, with the intent that this law is never changed.*

The third channel stands open and dark on purpose. It is witnessed only where Body
and Mind interact — never written directly — the way Force is real yet has no stat.
It is not counted among the four operative primitives, because it is never
instantiated. *A blank is never filled for convenience;* this one is kept forever.

---

# III · The three canonical verbs — SIGNED

The Kernel has exactly three verbs. They exist forever. Everything else is an
alias that reduces to one of them.

```text
SPACE · EFFECT · TIME
MOVE  · ACTION · WAIT
```

## MOVE — changes Position now
MOVE acts on the acting entity and writes directly to Position.
```text
MOVE → choose legal destination or trajectory → pay Agency → change Position
```
Sprint · Leap · Teleport · Withdraw · Sail · Approach reduce to MOVE.
MOVE stays its own verb because **Position is a substrate, not an effect** — it is
never collapsed into ACTION even though a movement *could* be modelled as a packet.

## ACTION — resolves a PACKET now
```text
ACTION → select PACKET → select target → verify constraints → resolve → apply effects
```
Attack · Use · Cast · Heal · Repair · Persuade · Accuse · Interact · Hack are
**presentation** for ACTION. They are not separate Kernel verbs.

An ACTION may target **Self · another agent · an object · a point · an area · any
legal target the owning module defines.** The **PACKET** decides what happens.
An effect helps, harms, enables, or obstructs depending on target and context;
the Kernel carries no alignment tag (SIGNED). `→ G·packet-has-no-alignment`

## WAIT — arms a PACKET for later
```text
WAIT → select PACKET → declare/load its trigger → arm it → resolve when the trigger fires
```
Overwatch · Brace · prepared responses reduce to WAIT. WAIT changes **when** a
PACKET resolves; it does not spawn a second reaction system outside the PACKET
grammar. WAIT stays its own verb because **deferred timing** is its defining
property, not the packet it references.

### WAIT and the Written Trigger — SIGNED (William, 2026-07-25 · amended 2026-07-27)
Two things resolve on someone else's activation, and the Kernel keeps them apart:

```text
WAIT             the player spends 1 AP NOW to arm a PACKET of his choosing
Written Trigger  a PACKET carries its own trigger clause and fires when the
                 condition occurs — no AP, no arming, no cost
                 ↓
neither is budgeted. What limits them is Position, authoring, and death.
```

A **Counter** is a Written Trigger: the weapon or condition PACKET carries the
clause that permits it (Document B · 9).

**Overwatch is the instructive case.** You pay **1 AP to arm a better PACKET**
than your written triggers would give you. That is the whole transaction: the AP
buys **quality**, not permission — an armed WAIT resolves when its trigger fires.
`→ G·wait-is-not-a-written-trigger`

**A trigger fires once per occurrence of the condition it names**, and a movement
is **one occurrence** — a figure crossing a threatened band is one event however
finely the module slices the movement to resolve it. That, and not a pool, is what
stops a clause being milked. `→ G·a-pool-is-not-a-position`

## The distinction
```text
MOVE   changes Position   now.
ACTION resolves a PACKET  now.
WAIT   arms a PACKET       for later.
```
Lowercase "action" may describe any AP spend in prose. Uppercase **ACTION** is
the packet-resolving verb.

---

# IV · Agency & Resources

**AP is Agency** — the limited capacity an entity has to act during its **own
activation**. Unless a module says otherwise:
```text
1 AP  →  one MOVE, one ACTION, or one WAIT
```
Named abilities and flavour verbs never create new universal actions; they
translate to one of the three invariants (Law 11).

**Agency is the only pool a figure spends to act.** There is no second pool for
someone else's activation. `→ G·a-pool-is-not-a-position`

## Answering on someone else's activation — SIGNED (William, 2026-07-27)
**Out-of-turn response is not a Resource.** A triggered PACKET — a Counter, an
intercept, an opportunity strike, an armed WAIT — **costs nothing to resolve.**
Three things limit it, and none of them is a number:

```text
POSITION   the geometry has to permit it — contact, facing, range, presence
AUTHORING  the clause has to exist, and the striking PACKET has to provoke it
DEATH      a corpse answers once, on the way down, and never again
```

**Position is the cap.** A module that wants a figure to stop answering denies it
the geometry, not the budget — get behind him, stay out of contact, or kill him.
This is Ch. II load-bearing: *depth comes first from Position, not from stacks of
numerical modifiers.* A response pool was a second, numerical answer to a question
Position had already settled. It is struck (Document E · `reaction-struck`).

> **Earlier drafts carried a `Reaction` Resource** — `1 per figure · 2 for a
> Circle`, one spent per trigger. Struck 2026-07-27. Where it went:
> [Document D](D_MIGRATION_MAP.md).

## Resources
Agency is the Kernel's first exchangeable **Resource** — a limited quantity spent
to produce change. Each module implements the ones it needs:
```text
Agency · Health · Morale · Information · Influence · Supply · Time
```
Combat spends **Agency**; politics spends **Influence**; travel spends **Time +
Supply**. Same Kernel idea, made concrete per module.
`→ G·position-is-not-a-resource`

## The three Resource kinds — SIGNED (William, 2026-07-28)
A spendable Resource is classified by **how it replenishes** — a behavioural
classification (Law 10), read by humans and the UI, not a new primitive. There are
three, and the Kernel names each with a **neutral noun** and a **canonical colour**:

```text
KIND          COLOUR   BEHAVIOUR                              KERNEL NOUN
renewing      🟢 green  refreshes every activation / turn      Agency   (AP — already ours)
finite        🟡 yellow depletes; an action or event restores  Charge
accumulating  🔴 red    rises with use; vent it or it punishes  Strain
```

- **Packets are authored in the kernel nouns** — `spend 1 Charge`, `gain 1 Strain`,
  `spend 1 Agency` — never in setting words. A weapon that "reloads" *spends Charge*;
  one that "overheats" *builds Strain*.
- **The setting performs one final conversion at Presentation** (Ch. IX): the same
  `spend 2 Charge` renders as *"2 Ammo"* in a sci-fi skin, *"2 Arrows"* or *"2 Mana"*
  in a fantasy one. The engine only ever knows Charge and Strain. **Ammo and Heat are
  skins, not mechanics.** `→ G·a-resource-kind-is-not-a-mechanic`
- **Colour is the player's language**, and by the poka-yoke rule (Component Layer,
  Document J) it is **paired with a distinct shape**, never carried by hue alone.
- **Scope: costs only.** The three kinds classify quantities a packet *spends or
  gains*. **Health (Wounds) and Morale are State, not a colour** — what is currently
  true, not a cost — and stay owned by their existing procedures (Law 1).

The classification is deliberately genre-blind: the finite kind was already needed for
spell charges before firearms existed, which is why a gun's magazine reused it instead
of inventing an "ammo" system (Law 13 — the abstraction predates the feature).

---

# V · PACKET — the universal referenced definition — SIGNED

A **PACKET** is a **stateless, named, referenced definition of a resolvable
effect** — one universal data object. Weapons, spells, abilities, interactions,
reactions, impact effects, heals, and commands are all PACKETs.

A PACKET:
- has a **neutral ID** and a player-facing **name/alias**;
- **holds no runtime state** (Law 5);
- is **defined once, referenced everywhere** — never copied onto each card;
- may be **resolved by ACTION**, **armed by WAIT**, or **invoked by another owned
  procedure** (e.g. Impact);
- carries **only** what its resolution needs;
- does **not** encode whether it is "good" or "bad."

### Neutral identity
Typed IDs are retired. The primary ID never encodes packet kind:
```text
retired:  ATK_07   ABIL_04   REACT_02   PASSIVE_09
canonical: spear_thrust   healing_word   shield_intercept   wall_impact
```
```json
{ "packet_id": "spear_thrust" }
```
**SIGNED (William delegated → designed, 2026-07-24).** Classification lives in a
**separate sidecar registry** (`packet_index`), never in the ID. The primary ID
stays neutral; the sidecar maps it to retrieval dimensions so tooling can query
("all combat Melee packets") without parsing IDs:
```json
"spear_thrust": {
  "verb":    "ACTION",     // MOVE | ACTION | WAIT — how it is normally invoked
  "module":  "combat",
  "tool":    "Melee",      // the module Tool it belongs to (combat: Melee/Ranged/Hybrid)
  "targets": ["agent"],    // legal target kinds
  "tags":    ["reach"]     // free descriptive tags (incl. traits it pairs with)
}
```
The sidecar is **Definition-layer, stateless** (Law 5) and **one-owner** (the module
that owns the packets owns their index entries, Law 1). It is **additive**: a packet
with no index entry is still valid — the index only aids retrieval, never resolution.

### Provisional shape (conceptual, not frozen)
```text
PACKET = { id · name · constraints · cost · dice · success_number · grades · effects }
```
The **owning module** decides which fields its packets require.
`→ G·not-every-packet-rolls-dice`

---

# VI · Success Grade — SIGNED

The result of resolving a PACKET is a **Success Grade** (short: **Grade**) — how
well the PACKET succeeded. **Tier** and **Class** are reserved for persistent size
and organizational classification. Where *Ladder · Tiers · Rungs · Outcome Track*
went: [Document D](D_MIGRATION_MAP.md). `→ G·grade-is-not-a-tier`

```text
roll → count successes → determine Grade → resolve the Grade
```
> **Roll the PACKET, count successes, and resolve the highest Grade achieved.**

```text
SPEAR THRUST — Dice 5 · Success 4+
  GRADE 1 — Push
  GRADE 2 — 1 Wound
  GRADE 3 — 1 Wound + Guard
  GRADE 4 — 2 Wounds
```
- **Success** — a die that meets the PACKET's success number.
- **Grade** — how well the whole roll succeeded.
- **Effect** — what resolving that Grade changes.

Player language: *"Three successes — I made Grade 3."* Provisional data field:
`grades`.

> **SIGNED (William, 2026-07-24): Model 2 — Discrete.** Resolving Grade *N*
> resolves **only** the Effects written at Grade *N* — a higher Grade does **not**
> inherit lower Grades' Effects. Each Grade line is a complete, self-contained
> outcome; if a designer wants an Effect carried up the ladder, they write it on
> every line that should have it. This makes a PACKET's `grades` read top-to-bottom
> as independent results, not a running accumulation.

---

# VII · The four axes — Role · Tempo · Tool · Temperament

Four **independent** relationships with Force. They are never collapsed into one
another.
```text
ROLE        = what relationship with Force?
TEMPO       = how soon can it bring Force to bear?
TOOL        = by what method is Force delivered?
TEMPERAMENT = with what preference is Force applied?
```

## ROLE — relationship with Force (SIGNED: three roles)
```text
PRESSURE applies Force.     ANCHOR prevents Force.     UTILITY changes Force.
```
- **PRESSURE** — threatens, breaches, displaces, suppresses, pursues, exposes,
  overwhelms; forces the opposition to respond.
- **ANCHOR** — holds, blocks, absorbs, protects, delays, intercepts, preserves;
  denies hostile Force its intended change.
- **UTILITY** — amplifies, weakens, redirects, restores, reveals, coordinates,
  relocates, transforms; alters the conditions of Force. Utility absorbs what
  older drafts split into Control and Support.

Role names an agent's **primary** relationship with Force.
`→ G·role-is-not-a-job-list`

The older role words — Assault, Skirmisher, Control, Support, Reach, Projection —
survive as archetypes, tags, doctrines, or PACKET effects. Where each one went:
[Document D](D_MIGRATION_MAP.md).

## TEMPO — relative timing of Force (SIGNED: ordinal)
**Tempo is the time it takes to apply Force relative to its peers** — the interval
between an opportunity and the agent's next effective application of Force.
```text
>    Slow        >>   Normal        >>>  Fast

Artillery >     Tank >     Infantry >>     Cavalry >>>
```
An ordinal classification (Law 10). **Read by humans, never by the resolver** — it
is a vibe check that makes a card legible at a glance, and no procedure consumes
it. An artillery piece may out-range everything and still be Slow.
`→ G·tempo-is-not-speed` · `→ G·not-every-axis-needs-teeth`

## TOOL — delivery of Force
Tool defines **how Force is delivered** — the channel or mechanism through which
an agent expresses its Role. The same Tool may deliver Pressure, Anchor, or
Utility. `→ G·tool-does-not-set-purpose`

> **SIGNED (William, 2026-07-24).** The Kernel defines Tool **abstractly** and lets
> each module declare its own controlled Tool vocabulary. **The Combat Module's Tool
> set is `Melee · Ranged · Hybrid`** — an ordinal classification like Tempo (Law 10),
> where *Hybrid* covers a figure that delivers Force meaningfully both in contact
> and at a distance.

## TEMPERAMENT — preferred application of Force
Temperament is the agent's **behavioural bias** when several legal applications
of Force are available: when to commit, where to direct Force, which target to
prioritise, how much risk to accept, and what it does when command or cohesion
fails. Temperament describes **preference, not capability** — it never modifies a
die. `→ G·temperament-is-preference-not-capability`

**SIGNED (William delegated → designed, 2026-07-24).** Five Temperaments, each a
*preferred application of Force*:

| Temperament | Prefers to apply Force… |
|---|---|
| **Cowardly** | from safety — minimal risk, keep distance, act only with the odds |
| **Resolute** | steadily — hold position, commit to the objective, refuse to be drawn |
| **Aggressive** | forward — at the nearest threat, accepting risk to force the issue |
| **Protective** | to *prevent* Force on allies — shield, interpose, stay close to kin |
| **Ravenous** | at whatever is nearest — indiscriminate, heedless of side or cost |

The **leaderless** (AI-fallback) and **break/Rout** consequences of each live in
the Combat Module (Document B · Temperament table), since those behaviours are
combat procedures. The five words themselves are the signed Kernel axis.

---

# VIII · Creature Type vs Archetype

- **Creature Type — what the entity *is*.** Governs broad biological, morale,
  repair, healing, or targeting relationships owned by a module. Combat's set:
  `Man · Beast · Spirit · Construct`.
- **Archetype — *who* it is** in recognizable play language:
  `(Role + Tool + signature) → Archetype` → Gunslinger, Berserker, Assassin,
  Knight, Scout, Artillery. Say *Skirmisher* or *Sniper* at the table freely.
  `→ G·archetype-is-not-a-primitive`

---

# IX · Information architecture — the four layers

```text
DEFINITION  →  PROCEDURE  →  INSTANCE  →  PRESENTATION
(what it is)   (how it        (what is     (what the
               resolves)       true now)    player sees)
```
- **Definition** — static, referenced: a figure profile, a PACKET, a Formation, a
  Mission template, a Role, a Tool, a Tempo, a Temperament. **Holds no runtime
  state.**
- **Procedure** — the **owned** resolution method: movement, PACKET, Grade,
  Impact, Nerve, Rout, formation movement, social resolution, travel. A module
  owns its procedures.
- **Instance** — what is true **right now**: current Position, remaining Wounds,
  conditions, an armed WAIT, triggers already fired this occurrence, active Mission,
  current supplies, relationships. **Runtime state lives only here.**
- **Presentation** — what the player sees: flavour verbs, symbols, cards, models,
  markers. It **translates** the Kernel; it never forks a parallel mechanic.
```text
player sees:  ACTION → [weapon symbol] "Spear Thrust" → GRADE 1/2/3
system reads: ACTION → packet_id:spear_thrust → target → resolver
```

---

# X · Recursive organization

```text
FIGURE  acts within  FIRETEAM  maneuvers within  BANNER
        travels within  CARAVAN  coordinates into  ARMY  exists within  KINGDOM  →  WORLD
```
- **Figure** — one independent agent / one piece. Owns capability: `Role · Tempo ·
  Tool · Temperament · signature · PACKET references · stats`. **A Figure stays a
  complete agent even inside a higher formation** — there is no mode switch that
  strips its agency.
- **Fireteam** — the primary local maneuver element: a **Sergeant + ~3–5
  Retinue.** The Sergeant supplies coordination, Rally, formation handling, and
  command continuity.
- **Banner** — the warband / persistent tactical group: a **Champion + Fireteams +
  loose specialists.** `→ G·banner-is-not-a-command-state`
- **Caravan** — the **persistent expedition**: the body of people, beasts, wagons
  and materiel that travels between events. It is the **physical representation of
  the persistence axis** — an actual model on the table, read the way a base is
  read (B · 1). What it carries is legible from what it *is*: wagons, capacity,
  facilities, who is riding because they cannot walk.
  *(The Caravan is an **entity**, not a module. What persists and how it changes
  is owned by **Persistence**, Document H — not by the Caravan itself.)*
- **Army** — many Banners coordinated for a campaign.
- **Kingdom** — the political society containing institutions, law, Caravans, and
  Armies.

**Fractal law:** every layer is both (1) a complete game at its scale and (2) a
component of the layer above. Higher layers **compose** lower agents; they never
seize or erase agency.

---

# XI · Intent & Missions — the asymmetry is deliberate

- **Human side.** The human already supplies intent. **Never** apply an AI Mission
  script to a human player's own figures (Law 9).
- **AI side.** A **Mission** supplies *constrained* intent — `Intent · Priorities ·
  Focus · Constraints · Fireteam assignments` — and **narrows the decision
  problem** without puppeteering every Figure:
```text
MISSION → Fireteam assignment → Sergeant coordination
        → Figure judgment (Role · Tempo · Tool · Temperament · Position · PACKETs)
```
Missions are AI-only unless a future module explicitly creates a different
player-facing object.

---

# XII · The universal decision loop

Every conflict, at every scale, runs the same loop:
```text
OBSERVE → DISCERN → CHOOSE INTENT → ACT → CONSEQUENCES → PERSISTENCE
```
The Kernel supplies **structure**; players and Missions supply **intent**;
Procedures **resolve** outcomes; Instances **store** consequences; Persistence
**carries** them forward. Different modules swap procedures while the loop holds.

---

# XIII · The translation layer

The Kernel vocabulary is canonical. Every module **translates** it into its own
domain — renames, re-skins — and **never invents a parallel mechanic** (Law 11).
```text
KERNEL     MOVE        ACTION        WAIT
Combat     MOVE        Strike        Brace
Naval      Sail        Broadside     Brace for Impact
Social     Approach    Challenge     Prepare Response
Politics   Lobby       Accuse        Wait
```
Read *down* a column: a different game. Read *across* a row: the **same verb**.
Every ability's **name** carries theme; its **verb** carries the rules. Click the
name, land on MOVE, ACTION, or WAIT.

---

# XIV · The formal grammar

Every mechanic is one sentence in one grammar:
```text
STATEMENT  =  VERB  +  TARGET  +  AREA  +  CONSTRAINTS  +  EFFECTS
```
- **Verb** — MOVE · ACTION · WAIT.
- **Target** — Self · Agent · Object · Point · Area · a Trigger window (for WAIT).
- **Area** — none · a radius · a template.
- **Constraints** — range · line-of-sight (`los`) · trajectory (`path` — a clear arc
  exists; over cover, not through solid) · cost · legality. Each is a named packet
  field (Law 15): a bullet is `los:true`, a lobbed grenade `los:false · path:true`.
- **Effects** — the state changes produced (for ACTION/WAIT, by the PACKET).
```text
MOVE   · Self          · 6"  · —              · Position change
ACTION · Agent         · —   · in range       · resolve PACKET → Grade → Effects
WAIT   · Trigger window· —   · one armed PACKET· resolve the PACKET when it fires
```
Zoomed in, every resolution has the same morphology —
`VERB + OBJECT + MODIFIER + RESOLVER + OUTCOME` — and a module supplies its own
**Resolver** without changing the sentence shape. A single authoring tool can write
combat, diplomacy, and trade because it learns one morphology and swaps the
Resolver.

## Verb vs. Invocation — SIGNED (William, 2026-07-25)
The three verbs are what a **player** may choose. They are not the only way a PACKET
gets resolved: a Counter fires from a written trigger, an Impact fires from the
collision a MOVE created, a Shield Intercept fires from a trait. None of those began
with a player choosing a verb, so the grammar needs one more slot — **not** a fourth
verb.

```text
INVOCATION = MOVE | ACTION | WAIT | WRITTEN_TRIGGER | OWNED_PROCEDURE
             └──── the player's three ────┘  └── the engine's two ──┘

RESOLUTION = INVOCATION + TARGET + AREA + CONSTRAINTS + RESOLVER + EFFECTS
```

- **MOVE · ACTION · WAIT** — chosen by a player, paid in **Agency**.
- **WRITTEN_TRIGGER** — a clause inside a PACKET fires on its condition. **Paid by
  nobody** (Ch. IV): it costs no Resource, it fires **once per occurrence** of the
  condition it names, and it is gated by Position and by authoring.
- **OWNED_PROCEDURE** — a module's own procedure invokes a PACKET as part of
  resolving something else: Impact, Nerve, a fall, aftermath. Paid by whatever that
  procedure says, often nothing.

**The player still has exactly three verbs.** What the Kernel gains is an honest
account of how everything else reaches the resolver, instead of pretending a
Counter was somehow a WAIT. `→ G·three-verbs-is-not-three-invocations`

---

# XV · Architectural laws

Every module and every edit obeys these.

1. **One owner.** Every concept has exactly one owner; no layer stores a second
   authoritative copy of another's information.
2. **One module.** Every mechanic belongs to exactly one module.
3. **Compose, don't replace.** Higher layers compose lower layers.
4. **Recurse.** The same grammar applies at every scale.
5. **No state in Definitions.** Runtime state lives only in Instances.
6. **Intent vs. resolution.** Players and Missions choose intent; owned Procedures
   resolve outcomes.
7. **Shared primitives.** Modules communicate through Kernel primitives, not
   bespoke cross-module mechanics.
8. **Descriptive geometry.** Where precision doesn't improve the decision, use
   physical truth and honest judgment over measurement bureaucracy.
9. **Missions are AI-only.** Never automate the human player through the AI
   command grammar.
10. **Facts vs. judgments.** Store stable facts; compute situational judgments
    when needed. A designer-assigned classification (e.g. **Tempo**) must be
    identified *as* a classification, never disguised as a measured statistic.
11. **Translate, don't fork.** Modules translate MOVE · ACTION · WAIT; they never
    invent parallel universal actions.
12. **No preferred implementation.** Combat is the reference implementation, not
    the Kernel's master.
13. **Primitives are atomic; composites reduce.** Every composite reduces to
    primitives with no unexplained remainder. A genuine new primitive is a
    constitution change.
14. **One grammar, one resolver.** Every mechanic has one structured statement and
    exactly one owned Procedure that resolves it.
15. **An exception is a named field, never prose** — SIGNED (William, 2026-07-28).
    A deviation from the default may exist *only* as a named, owned field a tool can
    read (`provokes`, `not_in_contact`, `los`, a trait keyword, a PROVISIONAL marker,
    a `→ G·` slug), never as a special sentence buried in the rules. The test: **can
    this be a field?** If yes, it goes in the container — typed, priced, queryable. If
    no, it is not an exception at all; it is a **missing layer** (Principle 8, *layers
    not exceptions*). You do not delete exceptions; you give them passports.
    `→ G·an-exception-is-a-named-field`

---

# XVI · Design principles

- **Cognitive economy** — a rule must justify the attention it costs.
- **Progressive complexity** — deeper layers stay optional.
- **Readability first** — minimize time-to-understanding.
- **Physical truth** — the table answers before the rulebook.
- **Information where needed** — players never hunt for facts.
- **Honest judgment** — precision only where it improves the decision.
- **Player agency** — procedures resolve choices; they never make them.
- **Determinism as trust** — after resolution, nobody negotiates the result.
- **Theme serves mechanics** — flavour clarifies the grammar without forking it.
- **Fail gracefully** — play continues when an edge case appears.
- **Layers, not exceptions** — a recurring exception means a missing layer.

**The razor.** *Does the mechanic read or write **Position, Force, State, a
Resource, or a relationship between agents**?* If not, decide whether it is
necessary structure or free-floating clutter — and cut the clutter.

---

# XVII · The module contract

A new module (Combat, Politics, Caravan, War, Trade, …):
1. **cites** this Constitution and the Dictionary; it does not restate structure;
2. **translates** MOVE · ACTION · WAIT into its domain language (Ch. XIII);
3. **owns** its Procedures, its controlled **Tool** vocabulary, its Resource
   budgets (e.g. the AP allowance, Ch. IV), and its **Temperament
   procedures** — but **not** the Temperament vocabulary: the five words are
   Kernel law (Ch. VII) and a module may not add, rename, or drop one;
4. **stores facts, computes judgments** (Law 10);
5. reduces every mechanic to a primitive relationship — or marks a true
   constitutional question in **Document E** rather than inventing an answer.

Combat's obligations are discharged in **Document B**; every Combat mechanic there
cites the Kernel primitive it reads or writes. The other two domains are declared
in Ch. XIX and are **not yet discharged.**

---

# XVIII · Open-question register (pointer)

**Every decision is signed** (William, 2026-07-24) and folded into A/B/C. **CUS v0.6
is closed** — no open constitutional questions remain. Full record in
**[Document E](E_OPEN_DECISIONS.md)**:

```text
SIGNED  grade-accumulation   · Model 2 (discrete — Grade N resolves only its own Effects)
SIGNED  persistent-traits    · Option B — referenced passive Definitions; keyword: trait
SIGNED  tool-vocabulary      · combat Tool set = Melee / Ranged / Hybrid (vibe-check)
SIGNED  temperament          · five words + leaderless/Broken behaviour table (B · 10)
SIGNED  force-ontology       · Force IS a formal Kernel primitive (non-numerical)
SIGNED  packet-classification· neutral ID + separate packet_index sidecar (designed)
SIGNED  base-classes         · Small / Medium / Large (no Monstrous, no Cavalry-as-class)
SIGNED  engagement           · bases touching = engaged · Reach 1–2″ · Disengage 1 AP
SIGNED  counter              · turn-and-face · no cap · dying swing · Circles faceless
SIGNED  counter-loop         · a Counter does not itself draw a Counter
SIGNED  morale-states        · Steady → Shaken → Broken (Broken = Rout by Temperament)
SIGNED  nerve-trigger        · shock (wounded / ally falls within 3″) → roll 3, count Nerve
```

**Amendments — signed 2026-07-25 (William).** v0.6 stays closed; these are
recorded amendments, not reopened questions:
```text
STRUCK  reaction-resource    · struck 2026-07-27 — see below
STRUCK  reaction-budget      · struck 2026-07-27 — see below
SIGNED  counter-authoring    · a Counter is a written trigger inside a PACKET, not a WAIT
SIGNED  modules              · TWO peer modules: COMBAT · STORY (Ch. XIX). Persistence
                               is Kernel architecture, not a module — reserved (2026-07-26)
SIGNED  brace-vs-overwatch   · Brace and Overwatch are the two WAITs — Brace buys bonuses
                               and step-ups, Overwatch buys a better armed PACKET (revised)
SIGNED  sprint-to-charge     · a 3″ uninterrupted sprint into contact is the charge threshold (B·3)
```

**Amendment — signed 2026-07-27 (William). The Reaction economy is struck:**
```text
SIGNED  reaction-struck      · Reaction is no longer a Resource. No pool, no budget,
                               no per-trigger cost, anywhere (Ch. IV, Ch. XIV)
SIGNED  counter-is-free      · a Counter costs nothing. Limits: contact · facing ·
                               authoring · death (B·9)
SIGNED  provokes             · the STRIKING packet decides whether it draws a Counter —
                               `provokes`, true by default for melee resolved in contact
SIGNED  trigger-once-per-    · a Written Trigger fires once per occurrence of its
        occurrence             condition; a movement is one occurrence (Ch. III, F)
SIGNED  wait-buys-quality    · WAIT is the only AP-priced out-of-turn capability, and it
                               buys quality, not permission. "Arming is not permission"
                               is struck — with no pool to be empty, arming IS permission
SIGNED  facing-is-the-cap    · what replaces the pool is the front arc: an engaged Square
                               answers its face and concedes its flanks; a Circle, being
                               faceless, answers everyone (B·8, B·9)
```

---

# XIX · The two modules — SIGNED (William, 2026-07-26)

The Kernel has **two implementations**: one for the fight, one for everything
said. They are **peers** under the module contract (Ch. XVII) — neither is a
species of the other, and Combat is not the master (Law 12).

```text
COMBAT  ── Document B ──▶  contested force        what you can do to them
STORY   ── Document I ──▶  contested everything    what you can do about them
                                                   else
                    both meet at THE FIGURE
```

| Module | Owns | Resolves |
|---|---|---|
| **COMBAT** | physical conflict — Position, Force, the clash | a strike |
| **STORY** | the parley, the bargain, the grudge, the oath, the crowd | an Ask |

**Story is the name.** Not *Meaning*, not *Social*, not *Bond* — the word people
actually use for the thing. If a rule needs a longer name than the thing it
governs, the rule is wrong.

## The razor already had the slot
Ch. XVI asks whether a mechanic reads or writes *"Position, Force, State, a
Resource, **or a relationship between agents**."* Combat owns Position and Force.
That last clause is **Story's**, and it was unowned until now. No fifth primitive
was required, which is the real test this architecture had to pass.

## What a module must do
The load-bearing clause of the contract is **translation**: a module that cannot
express MOVE · ACTION · WAIT in its own terms is not a module, it is a database.

```text
KERNEL   MOVE                    ACTION                     WAIT
Combat   MOVE                    Strike · Cast · Interact   Brace · Overwatch
Story    approach · distance ·   Address — promise ·        Prepare — a VOW
         side with · abandon     accuse · confess · forgive
```

A **vow** is a WAIT — something spent now, armed against a later trigger. A
**grudge** is a **Written Trigger** (Ch. XIV) — a clause carried inside a Figure
that fires when its condition occurs, armed by nobody. The invocation layer built
to explain a Counter turns out to explain the difference between swearing an oath
and holding a hatred, with no new machinery.

## Why Combat was built first
It has the tightest tolerances: an error is visible immediately, at the table, in
positioning and timing. Having survived that, the grammar is proven, and Story
inherits a foundation instead of laying a second one.

## Persistence is not a module — ⚠ RESERVED
What survives between events — injuries, scars, advancement, the Caravan, the
clock — is **Kernel architecture, not a peer implementation.** It is not a third
thing the Figure does; it is what the Figure *is* when nothing is happening.

**William is writing it into this Constitution.** Until he does, the harm and
aftermath procedures live in **[Document H](H_PERSISTENCE.md)** as a holding pen —
playable, but awaiting absorption. Do not cite H as a domain.

## Interface commitment
- **Play is analog.** Miniature, card, dice, pencil. No screen at the table.
- **Campaign bookkeeping requires the companion application** — SIGNED (William,
  2026-07-25). A deliberate commitment, not a fallback.
- **The physical component system is discharged in [Document J · The Component
  Layer](J_COMPONENTS.md)** — SIGNED (William, 2026-07-27). J is Presentation (Ch.
  IX), not a module: it translates State onto the model, Definition onto the card,
  and Persistence into the app, and it may not fork a mechanic. Its **Component
  Law** — *state on the model, capability on the card, campaign in the app; encode
  the exception, not the default; the base is the measuring instrument* — is the
  physical face of this commitment.

## Status
```text
COMBAT   BUILT      — Document B; the clash spine is closed (F)
STORY    PROPOSED   — Document I; drafted, unsigned, register at its foot
HARM     HOLDING    — Document H; playable, awaiting the Kernel rewrite
```
