# CUS — THE MEANING MODULE

### v0.6 · 🚧 **SCAFFOLD — UNDER CONSTRUCTION** 🚧 · opened 2026-07-25

> ```text
> ┌─────────────────────────────────────────────────────────────┐
> │                    UNDER CONSTRUCTION                       │
> │                                                             │
> │  This document is a DOOR, not a room. It declares what      │
> │  Meaning will own and what it must answer. It contains      │
> │  no rules yet and is NOT AUTHORITY.                         │
> │                                                             │
> │  Nothing here may be cited to settle a question.            │
> │  Where it conflicts with A–G, A–G wins.                     │
> └─────────────────────────────────────────────────────────────┘
> ```
>
> **What this will be.** The third of the three domains (A · XIX): the module that
> owns **standing relationships between agents, and what events meant.** Peer to
> Combat, not decoration on top of it.
>
> **Name.** **MEANING** is the Kernel term. ***Story*** is the everyday word — use
> it freely in conversation, on cards, and to players. Rejected: *Bond* (names one
> subsystem), *Identity* (covers who you are, not what you owe), *Character*
> (collides with Creature Type, Archetype, and player-character).

---

# 1 · Why this domain exists — the razor already had a slot

The Constitution's razor (A · XVI) asks whether a mechanic reads or writes:

```text
Position · Force · State · a Resource · OR A RELATIONSHIP BETWEEN AGENTS
                                          └──────────┬──────────┘
                                                  unowned
```

**Combat** owns Position and Force. **Persistence** owns State and Resource. That
last clause has been sitting in the Constitution since the rebuild with nobody
holding it. It is Meaning's.

That is the whole justification. No new primitive is required — which is the
outcome Law 13 wants.

---

# 2 · What Meaning owns

```text
BONDS            the standing tie between two agents — the domain's core object.
                 loyalty · grudge · kinship · debt · trust · rivalry
                 promises · obligations · oaths

STANDING         reputation with a person, a faction, a place

RECORD           significant events · what a Figure has done and had done to it
                 history that later matters

INTERPRETATION   what a recorded event MEANT to the people it happened to
```

**The division of labour with Persistence is strict:**

```text
PERSISTENCE  records that Bram killed Aldous.
MEANING      owns that Aldous's brother has not forgotten.
```

Persistence records truth and never invents meaning. Meaning interprets events and
**never alters the record.**

---

# 3 · Verb translation  *(this is the interesting part)*

A domain that cannot express the three verbs is a database, not a module
(A · XVII). Meaning translates cleanly — and the last row is why this architecture
is probably right.

```text
KERNEL   MOVE                    ACTION                     WAIT
Meaning  approach · distance ·   promise · accuse ·         a VOW
         side with · abandon     confess · forgive ·
         (change your standing)  pay a debt · betray
```

## A vow is a WAIT. A grudge is a Written Trigger.

Both resolve later. They are **not the same object**, and the Kernel already knows
the difference (A · III, A · XIV):

```text
VOW      the agent SPENT something now to arm a promise against a future trigger.
         Chosen. Declared. Costly. → WAIT

GRUDGE   a clause the Figure simply CARRIES. Nobody armed it. It fires the moment
         its condition is met — you walk into the room and it is already resolving.
         → WRITTEN_TRIGGER
```

The invocation layer was built to explain why a Counter is not a WAIT. It turns out
to explain the difference between **swearing an oath** and **holding a hatred** —
with no new machinery. That is the strongest available evidence that Combat,
Persistence and Meaning are one Kernel rather than three games sharing a logo.

⚠ **Drafted, not signed.** The first real procedure written here must honour this
or replace it.

---

# 4 · Temperament is the shared axis — one value, two procedures

Temperament is already cross-domain and needs **no duplicate field.** The five
words are Kernel law and a module may not add, rename or drop one (A · XVII); what
each module owns is its **procedures** for reading them.

```text
RESOLUTE

  Combat procedure   hold position, resist displacement, commit to the objective
  Meaning procedure  values duty, continuity, keeping promises
```

One Figure, one Temperament, two interpretations. Meaning may expand the
*expression* of a Temperament; it may not change its combat meaning.

This is the template for the whole domain: **reuse Kernel concepts, add
procedures, invent nothing.**

---

# 5 · The harm seam — where Meaning becomes load-bearing

Persistence owns the **injury and scar lifecycle** (H · 7). Meaning owns two things
inside it, and they are what stop this domain from being decoration.

## Meaning supplies the events that wound the MIND
BODY harm comes from damage. **MIND harm comes from what happened** — an ally dead
in your hands, a rescue that was a trap, being the only one who walked away. Those
are events, and events are Meaning's.

**The eight triggers are written and live in H · 7.6.** Meaning owns *recognising
that one occurred* and recording what it meant; Persistence owns what it does to
the figure. When Meaning gains a real event vocabulary (§8.3), those eight are its
first consumers.

```text
COMBAT   ── wounds ──▶  BODY injury  ──▶  BODY scar
MEANING  ── events ──▶  MIND injury  ──▶  MIND scar
```

## A MIND scar is a Written Trigger
Structurally identical to a grudge (§3): a clause the Figure carries, firing when
its condition is met, armed by nobody. William's case, worked:

```text
never_again
  origin   a child ran from a burning barn screaming for help. It was not a child.
  trigger  a child — or a thing wearing a child — calls for help
  effect   will not MOVE toward it; treats it as hostile until proven otherwise
```

**Persistence owns the scar and its mechanical effect. Meaning owns the event and
what it meant. Combat reads a clause and never learns why.** Three domains, one
Figure, one machinery — this case is the architecture working.

## Relationships heal the mind
Recovery is asymmetric on purpose (H · 7.6):

```text
BODY heals with CARE and TIME     surgeon · wagon · rest
MIND heals with RELATIONSHIPS     kin · a companion · someone who was there
```

A figure with no Bonds does not recover from what he saw — every MIND injury simply
runs to its neglect column, and that column ends at **`hollow`** (H · 7.7b): he
cannot form or hold a Bond, he cannot mend anything between people, and he lashes
out at whoever is nearest when it gets bad. **A man who is alone stops being able
to stop being alone.**

**Being alone is a mechanical disadvantage, not a mood** — which is what makes
Meaning a module rather than flavour text, and makes the chaplain worth as much
roster space as the surgeon.

> **Note for editors.** `hollow` restricts what *he* can do. It has never
> restricted what anyone else may do to him, for him, or beside him, and it must
> not start. See `G·there-is-no-redemption-rule`.

---

# 6 · Guardrails

The fourteen **Architectural Laws (A · XV) apply unchanged** — they are not
restated here, because a paraphrase silently disagrees with the original the first
time a Law is amended.

Specific to this domain:

1. **Meaning interprets events; it never alters the record.**
2. **Meaning does not rewrite combat resolution.** It reaches Combat through
   Instance fields the resolver already knows how to read — a grudge changes target
   preference, a fear changes Temperament behaviour, and the resolver never learns
   why.
3. **The AI prepares situations; it never authors player choices** (Law 9 already
   forbids scripting a human's figures — this extends it to their *feelings*).
4. **Generated possibilities stay provisional until chosen or triggered.**

---

# 7 · The AI Director  🔒 **slot reserved**

Deliberately left empty. The previous `F_AI_DIRECTOR` — a combat activation
heuristic — was **deleted on purpose** (commit `12aaf76`) to clear this name for a
campaign-preparation system of William's own design.

What is already settled about it: it solves the *preparation* problem, it reads
world state and offers hooks, and its output is an **artifact** — a briefing, a
map, a scenario — not a chatbot at the table. Players choose; it never decides what
anyone believes.

**Do not fill this in without William.**

---

# 8 · Open work

### 8.1 · The Wide State Read  ← the crown jewel
The canonical, structured statement of what is currently true, which the Director
reads before generating anything. It must answer: what is true, what changed last
session, who is involved, what relationships exist, what is unresolved, what is
merely *rumoured*.

**Its architectural position:** the Wide State Read is the **Instance layer at world
scale** (A · IX). By the fractal law (A · X) the same read should work at Banner,
Caravan and Kingdom scale — it is not a new kind of object, it is the existing one
zoomed out.

Hooks and prose are cheap and disposable. **The state model is not.** Accurate
state ⇒ coherent generation, because every possibility projects from one truth.

*Not the first thing to build* — it is the biggest schema in the project, and it
should be designed once two real subsystems have shown what they need to read from
it.

### 8.2 · Relationship representation
Directed or mutual? Graded or binary? Does a grudge decay? Can it be discharged?

### 8.3 · Event records
The vocabulary Combat emits and Meaning consumes (H · 5). Actor, target, act,
witnesses — enough for a later rule to fire on, without becoming prose.

### 8.4 · Abundant hooks, singular commitment
Generation is cheap, so many possibilities can exist without a human authoring
each. Only one activates. **All of them must project from one canonical state** —
contradictory hooks turn a persistent world into procedural noise.

### 8.5 · Reputation scope
With whom? A person, a faction, a settlement, the world? Does it travel?

---

# 9 · Module contract status  (A · XVII)

```text
1. cites the Constitution and Dictionary          ✅
2. translates MOVE · ACTION · WAIT                ⚠  drafted, §3, unproven
3. owns its Procedures                            ❌  none written
4. stores facts, computes judgments               ❌  no schema
5. reduces every mechanic to a primitive          ✅  claims the razor's
                                                     relationship clause (§1)
```

**Until line 3 has something in it, this is a door with a sign on it.**
