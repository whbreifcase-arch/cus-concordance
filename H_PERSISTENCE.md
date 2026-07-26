# CUS — THE PERSISTENCE MODULE

### v0.6 · 🚧 **SCAFFOLD — UNDER CONSTRUCTION** 🚧 · opened 2026-07-25

> ```text
> ┌─────────────────────────────────────────────────────────────┐
> │                    UNDER CONSTRUCTION                       │
> │                                                             │
> │  This document is a DOOR, not a room. It declares what      │
> │  Persistence will own and what it must answer. It contains  │
> │  no rules yet and is NOT AUTHORITY.                         │
> │                                                             │
> │  Nothing here may be cited to settle a question.            │
> │  Where it conflicts with A–G, A–G wins.                     │
> └─────────────────────────────────────────────────────────────┘
> ```
>
> **What this will be.** The second of the three domains (A · XIX): the module
> that owns **what remains true between events.** Peer to Combat, not beneath it.
>
> **How to use it now.** As a place to put things. When a persistence question
> comes up mid-work, write it into §7 rather than answering it in passing.

---

# 1 · What Persistence owns

The long-lived facts about a Figure, a Caravan, and the world.

```text
FIGURE          lasting injuries · scars · advancement · experience
                equipment carried · conditions that outlive a battle
                availability (fit / recovering / dead / missing)

CARAVAN         supplies · wealth · beasts · wagons · civilians
                crafting facilities · roster · what survived

WORLD           what changed and stayed changed
                the campaign clock
```

**Persistence records truth. It does not decide what that truth meant** — that is
MEANING's job (Document I), and the split is deliberate.

---

# 2 · Persistence is the module; the Caravan is the entity

A correction worth writing down before it becomes folklore:

```text
Combat       is the module.   Figure · Banner   are what it operates on.
Persistence  is the module.   THE CARAVAN       is what it operates on.
```

**Caravan is not a flavour-name for Persistence.** It is a canonical Kernel term —
a layer in the recursive hierarchy (A · X) — and it is a **real model on the table:
the physical representation of the persistence axis.** Wagons, capacity, facilities,
who is riding because they cannot walk. You read it the way you read a base (B · 1).

> **"Progression lives in the Caravan" is struck — SIGNED (William, 2026-07-25).**
> It was pure flavour wearing an ownership claim's clothes, and it is what made an
> outside reader conclude the Caravan *was* the domain. **Progression lives in the
> Figure's Instance.** Persistence owns the procedures that change it. The Caravan
> is where those figures physically are.

Persistence is **what the Caravan does between events.**

---

# 3 · Verb translation  *(the module contract's load-bearing clause)*

A domain that cannot express the three verbs is not a module (A · XVII, A · XIX).

```text
KERNEL   MOVE                  ACTION                      WAIT
Persist  travel — the Caravan  craft · heal · trade ·      hold in reserve —
         relocates, marches,   recruit · repair · train    bank supply, keep a
         makes for the pass                                bed open, stand watch
```

⚠ **Unproven.** These are the obvious readings, not signed rulings. The first real
procedure written here has to honour them or replace them.

---

# 4 · The interface commitment — SIGNED (William, 2026-07-25)

```text
PLAY         is analog.   Miniature · card · dice · pencil. No screen at the table.
PERSISTENCE  requires the companion application.
```

This is a **deliberate architectural commitment, not a fallback.** Between-session
bookkeeping is the app's job. The analog floor covers *playing the game*; it does
not extend to *maintaining the campaign*.

Consequence to design against: **a printed QR code cannot be written to.** Whatever
the payload schema ends up being (§7.2), the physical code is fixed at print time
and everything mutable lives where it can actually change.

---

# 5 · The contract with Combat

Combat stays **sealed**. Persistence never reaches into the resolver; it hands
Combat inputs and reads Combat's outputs.

```text
PERSISTENCE ──▶ COMBAT INPUT ──▶ [ SEALED RESOLVER ] ──▶ DELTAS + EVENTS ──▶ PERSISTENCE
```

**In** — who is available, what they're carrying, what condition they're in, what
lasting injuries apply. Note this largely already exists in canon: constrained
intent for an AI force is a **Mission** (A · XI), so the input contract should
*produce a Mission*, not invent a parallel object.

**Out** — state deltas (what mechanically changed) and event records (what
happened, in a form MEANING can interpret).

> ⚠ **The output contract must have an analog tier.** If it exists only as JSON it
> works for two sessions and then quietly dies, because §4 says nobody has a screen
> open during play. Design the five things you scribble on paper *first*, and let
> the schema serialize that.

---

# 6 · Mostly new data, not new combat mechanics

The intended shape: Persistence extends Combat through **Instance fields**, not by
reopening the resolver. A lasting arm injury is a modifier the resolver already
knows how to read. It does not need to know it came from a wolf in the spring.

```text
NEW CAMPAIGN DATA  →  EXISTING COMBAT INPUTS  →  SEALED RESOLVER  →  DELTAS + EVENTS
```

If a Persistence feature requires a *new* combat mechanic, that is a signal to stop
and check whether the feature is really Persistence's.

---

# 7 · HARM — injury, healing and scars  🚧 *framework only*

> The shape is set below. **The tables are not written.** Everything here is
> structure; §8.1 is the content job.

## 7.1 · The lifecycle — one procedure, two axes

```text
WOUND            transient · numeric · resolved at the table          [B · 7]
   │
   │  the battle ends
   ▼
INJURY           persistent · has effects NOW · has a recovery clock
   │
   │  time + care
   ▼
RECOVERED  ─or─  SCAR            permanent · has effects forever
```

**Wounds are combat's. Injuries and Scars are Persistence's.** The fork already
exists in canon: `wounds_remaining = 0 → Knocked Out or Dead` (B · 7). A figure
that went down and lived is a figure that rolls for harm.

## 7.2 · The two axes — BODY and MIND

Same lifecycle, **different sources.** This is the part worth noticing:

```text
COMBAT   ── wounds ──▶  BODY injury  ──▶  BODY scar
MEANING  ── events ──▶  MIND injury  ──▶  MIND scar
                  PERSISTENCE owns the lifecycle for both
```

BODY harm comes from **damage**. MIND harm comes from **what happened**, which is
not the same thing and is not measured in Wounds. A figure can walk off the field
untouched and ruined.

## 7.3 · BODY — generated, not enumerated

Do not hand-author two hundred injuries. Generate them:

```text
LOCATION  ×  TISSUE  ×  SEVERITY   →   a specific, named injury

LOCATION   head · eye · torso · arm · hand · leg · foot
TISSUE     bone · joint · tendon/muscle · nerve · organ · skin
SEVERITY   minor · major · grievous
```

```text
leg  · joint  · minor     →  rolled ankle
leg  · bone   · major     →  broken ankle
leg  · tendon · grievous  →  torn achilles
arm  · joint  · major     →  dislocated shoulder
hand · joint  · minor     →  sprained wrist
```

Location comes from **what actually hit the figure** where the record supports it,
and is rolled where it doesn't.

### The injury record
```text
injury_id · axis · location · tissue · severity
active_effect    what it does while unhealed
recovery         periods required · whether care is required
on_heal          RECOVERED  |  SCAR:<scar_id>
on_neglect       what it becomes if untreated
```

### Worked example
```text
torn_achilles
  axis        BODY
  active      cannot Sprint; Move halved; cannot join a Form Up
  recovery    3 periods WITH care · never heals without it
  on_heal     SCAR:short_stride
  on_neglect  SCAR:crippled_leg — permanent, and he rides in the wagon
```

## 7.4 · MIND — triggered by events, not damage

MIND injuries are caused by things that happened, and the causing event is owned by
**MEANING** (Document I), not by Combat.

```text
TRIGGERS   an ally died in your hands · you failed to save someone
           you were the only one who walked away · you were betrayed
           you did something that cannot be undone · you saw a thing that
           should not exist
```

### The skinwalker case — the architecture's proof
William's example, worked all the way through:

> *A child runs out of a burning barn screaming. You break cover to put him out.
> As you reach him, he opens up like a flower and lunges. He was never a child.*

```text
MIND INJURY   haunted
  active      cannot Rally others; tests Nerve at a penalty near fire
  recovery    2 periods WITH companionship · does not heal alone
  on_heal     SCAR:never_again
  on_neglect  SCAR:hollow — will not close with anyone, ever

MIND SCAR     never_again
  trigger     a child — or a thing wearing a child — calls for help
  effect      this figure will not MOVE toward it, and treats it as hostile
              until something proves otherwise
```

**A MIND scar is a Written Trigger** (A · XIV). It is a clause the Figure simply
carries, firing when its condition is met, chosen by nobody — structurally the same
object as a grudge (I · 3). No new machinery is required to make trauma work.

## 7.5 · Scars are not just penalties

> **Design rule: a scar should change *how* a figure fights, not merely subtract
> from it.**

A man whose ankle never set right stops chasing people and learns to hold ground.
That is `short_stride`: −2″ Move, **+1 die while Braced**. He is not a worse
soldier, he is a *different* soldier, and he got that way by surviving something.

Veterans should be legible from their scars. A twenty-year man should read as a
list of things that nearly killed him and what each one taught him.

## 7.6 · Care — what the Caravan is for

Recovery is not automatic; it needs **care**, and care is a Caravan ACTION (§3).
This is what gives the physical Caravan model weight — a surgeon, a wagon, a warm
place to lie down are the difference between a scar and a cripple.

```text
BODY heals with CARE and TIME        →  surgeon · facilities · rest
MIND heals with RELATIONSHIPS        →  kin · a companion · someone who was there
```

**That asymmetry is deliberate.** It makes MEANING mechanically load-bearing rather
than decorative: a figure with no bonds does not recover from what he saw. Being
alone is a mechanical disadvantage, not a mood.

## 7.7 · How harm reaches Combat without reopening it

Every effect above is a modifier the resolver **already knows how to read** (§6):

```text
BODY scar  →  Move · dice · Wounds · Armour · a packet it may no longer use
MIND scar  →  a Temperament procedure modifier, or a Written Trigger
```

The resolver never learns that the achilles tore in the mud outside Greyfen, or
that the thing in the barn was not a child. It reads a number and a clause. The
meaning stays in MEANING.

---

# 8 · Open work

Nothing below is decided. Ordered by what unblocks the most.

### 8.1 · The harm tables  ← **start here**
The framework is §7. What is missing is **content**: the BODY injury table across
location × tissue × severity, the MIND injury list against its triggers, and the
scar catalogue both feed into. Author the scars *first* — they are the payoff, and
they tell you what injuries need to exist.

### 8.2 · The QR payload schema
What is on the code, what is referenced, versioning, what happens when a Definition
changes after printing. See the §4 constraint.

### 8.3 · The campaign clock
**Not started — deliberately low-res for now.** A campaign without a clock is a
series of unrelated fights. Time is already a Kernel Resource (A · IV) and nothing
spends it. When this opens: seasons, travel time, healing over weeks, and what
rivals do while you are elsewhere.

### 8.4 · The combat output schema
Analog tier first (§5), then the serialized form.

### 8.5 · Advancement
Experience, what it buys, and whether it can be lost.

### 8.6 · Ruin
What happens when the Caravan is destroyed. The genre's emotional engine runs on
permanent loss; there is currently advancement and no ruin.

### 8.7 · Whose persistence?
Everything above assumes the players' Caravan. If rival factions have state — and a
world where a beaten warband is weaker next time is a very different game from one
where it isn't — somebody owns that too.

---

# 9 · Module contract status  (A · XVII)

```text
1. cites the Constitution and Dictionary          ✅
2. translates MOVE · ACTION · WAIT                ⚠  drafted, §3, unproven
3. owns its Procedures and Resource budgets       ❌  none written
4. stores facts, computes judgments               ❌  no schema
5. reduces every mechanic to a primitive          ❌  no mechanics yet
```

**Until line 3 has something in it, this is a door with a sign on it.**
