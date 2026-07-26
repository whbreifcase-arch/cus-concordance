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

**Caravan is not a flavour-name for Persistence.** It is already a canonical
Kernel term — a layer in the recursive hierarchy (A · X), *"the primary persistent
expedition… **Progression lives in the Caravan**."* Treating it as a skin would
give one concept two owners (Law 1).

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

# 7 · Open work

Nothing below is decided. Ordered by what unblocks the most.

### 7.1 · The injury table  ← **start here**
The trigger already exists in canon: `wounds_remaining = 0 → Knocked Out or Dead`
(B · 7). *Did he get up after the battle?* is the entire emotional engine of the
genre, and it is one table. Small, finishable, and it forces the write-back problem
to be solved at a scope that can actually be completed.

### 7.2 · The QR payload schema
What is on the code, what is referenced, versioning, what happens when a Definition
changes after printing. See the §4 constraint.

### 7.3 · The campaign clock
**Not started — deliberately low-res for now.** A campaign without a clock is a
series of unrelated fights. Time is already a Kernel Resource (A · IV) and nothing
spends it. When this opens: seasons, travel time, healing over weeks, and what
rivals do while you are elsewhere.

### 7.4 · The combat output schema
Analog tier first (§5), then the serialized form.

### 7.5 · Advancement
Experience, what it buys, and whether it can be lost.

### 7.6 · Ruin
What happens when the Caravan is destroyed. The genre's emotional engine runs on
permanent loss; there is currently advancement and no ruin.

### 7.7 · Whose persistence?
Everything above assumes the players' Caravan. If rival factions have state — and a
world where a beaten warband is weaker next time is a very different game from one
where it isn't — somebody owns that too.

---

# 8 · Module contract status  (A · XVII)

```text
1. cites the Constitution and Dictionary          ✅
2. translates MOVE · ACTION · WAIT                ⚠  drafted, §3, unproven
3. owns its Procedures and Resource budgets       ❌  none written
4. stores facts, computes judgments               ❌  no schema
5. reduces every mechanic to a primitive          ❌  no mechanics yet
```

**Until line 3 has something in it, this is a door with a sign on it.**
