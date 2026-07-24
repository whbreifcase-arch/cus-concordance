# CUS — THE KERNEL DICTIONARY
### v0.6 · one canonical definition per term · 2026-07-23

> The Rosetta Stone. Every module checks its words here. If a word isn't in this
> Dictionary, either add an alias to an existing entry or the word is inventing a
> mechanic (forbidden, Law 11). Entries note the **owner** and what the term
> **reads / writes / consumes / creates.**

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
The limited capacity an entity has to act during its activation; carried as **AP**.
Unless a module says otherwise, **1 AP buys one MOVE, one ACTION, or one WAIT.**
**Owner:** Kernel. **Consumed by:** the three verbs. One of the exchangeable
Resources.

### Resource
Any limited quantity spent to produce change: `Agency · Position · Health ·
Morale · Information · Influence · Supply · Time`. **Owner:** Kernel; each module
implements the resources it needs.

---

## The three verbs

### MOVE
The verb that **changes Position now**. Acts on the acting entity; writes directly
to Position. **Owner:** Kernel. **Consumes:** Agency. **Creates:** a Position
change. **Aliases:** Advance · Sprint · Leap · Teleport · Withdraw · Sail ·
Approach.

### ACTION
The verb that **resolves a PACKET now** against a valid target. **Owner:** Kernel.
**Consumes:** Agency. **Creates:** the PACKET's Effects (via a Grade). **Aliases:**
Strike · Attack · Use · Cast · Heal · Repair · Persuade · Accuse · Interact · Hack.
*(Uppercase ACTION = this verb; lowercase "action" = any AP spend in prose.)*

### WAIT
The verb that **arms a PACKET against a trigger**, deferring its resolution.
**Owner:** Kernel. **Consumes:** Agency (and the figure's reaction). **Creates:** a
primed `trigger → resolution`. **Aliases:** Brace · Overwatch · Intercept ·
Counter · Prepare Response · Wait.

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
**Owner:** the resolving Procedure. Replaces Ladder/Tiers/Rungs. **Discrete
(Model 2, SIGNED William 2026-07-24):** resolving Grade *N* resolves **only** the
Effects written on Grade *N* — no inheritance of lower Grades' Effects. **Not** to
be called a Tier.

### Effect
The state change a resolved Grade produces (Wound, Push, Knockdown, Guard, heal,
reveal, …). **Owner:** the PACKET (defined) / the Procedure (applied). **Writes:**
State (or Position, for displacement Effects).

### Trait
An **always-true** property a Figure carries — a **referenced passive Definition**
(SIGNED William 2026-07-24; keyword **trait**). Defined once, referenced by ID
(`{ "trait_id": "reach" }`), like a PACKET but **passive**: it resolves nothing and
holds no runtime state. Examples: Large, Flying, Mounted, Fearless, Amphibious,
Reach, Unstoppable. **Not** a PACKET, **not** a size class. **Owner:** the module
that defines it.

---

## The four axes

### Role
An agent's **primary relationship with Force**. **Owner:** Kernel. Exactly three:
**Pressure · Anchor · Utility.** Names the agent's main relationship, not every
effect its PACKETs can produce.

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
The **relative timing of Force**: how soon an agent can bring its Role to bear
compared with others in the same environment. **Ordinal, not a formula:**
`> Slow · >> Normal · >>> Fast`. A designer-assigned **classification** (Law 10),
never a measured statistic; not Move distance, initiative, range, AP, or damage.

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
(Gunslinger, Berserker, Knight, Scout, Artillery). A readable combination, **not a
primitive.** Old role words (Skirmisher, Tank, Sniper, Support) may survive here.

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
specialists.** Not an Order, a Mission, a command-state, or a flag-bearer.

### Caravan
The primary **persistent expedition**; physically carries what survives between
events (figures, Banners, civilians, wagons, supplies, injuries, wealth, quests,
relationships, reputation, crafting facilities). **Progression lives here.**

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
What is true of an Instance right now and can change: Wounds, conditions, morale,
armed WAIT, activation flags. **Written by** Effects and Procedures; **stored** in
the Instance.

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
