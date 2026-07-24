# CUS — OPEN DECISIONS
### v0.6 · genuine unresolved calls · 2026-07-23

> These are the questions the rebuild **deliberately does not answer.** Each is
> stated with its coherent options and their trade-offs, and each carries a blank
> **RULING** line awaiting the owner. Per the Brief, nothing here is resolved by
> the assistant. A blank in this document is **not** an omission — it is a
> question waiting for you.
>
> When you sign one, move the ruling into the cited section of A/B/C and strike it
> here.

## Status board

| ID | Question | Blocks |
|---|---|---|
| E·grade-accumulation | Higher Grade: inherit lower Effects, or only its own? | PACKET resolution (B·5), unit data |
| E·persistent-traits | Where do Large / Flying / Fearless / Reach live? | Figure schema, PACKET boundary |
| E·tool-vocabulary | What are the Tools? | Archetype math, card bindings |
| E·temperament-vocabulary | Exact list + behavioural consequences | Nerve/leaderless procedure |
| E·force-ontology | Is Force a primitive, a relationship, or a lens? | Kernel primitive count |
| E·packet-classification | The separate classification/retrieval JSON | Packet registry, tooling |
| E·combat-aftermath | Counter / Nerve / Shaken / Rout / Rally / Wild | Combat resolver |
| E·base-millimetres | Exact round & oval standards | Base/manufacturing spec |

---

## E·grade-accumulation
**Question.** When a PACKET reaches Grade *N*, does it also resolve the Effects
written at every lower Grade, or only the Effects written at Grade *N*?

- **Model 1 — Inherit (accumulate).** Grade 3 resolves Grade 1 + 2 + 3 Effects
  (with the old "highest Wound wins, every passed Effect accumulates" flavour).
  *Trade:* richer top-end results; each Grade line is additive and you must design
  Effects that stack cleanly; a big roll does a lot at once.
- **Model 2 — Discrete (own Effects only).** Grade 3 resolves **only** the Grade 3
  line. *Trade:* each Grade is a clean, self-contained outcome; designers write the
  full result on the reached line; easier to read, but lower lines must repeat any
  Effect they want carried up.

*Consequence either way:* every combat PACKET's `grades` must be authored to the
chosen model; they are not interchangeable. The Combat Module (B·5) will not sign
a resolver until this is fixed.

**RULING:** ⬚ *unsigned.*

---

## E·persistent-traits
**Question.** Where do always-true properties — **Large, Flying, Mounted,
Fearless, Amphibious, Reach** — live?

- **A — Figure Definition attributes.** A flat trait list on the figure. Simple;
  risks becoming a junk drawer.
- **B — Referenced passive Definitions.** Each trait is its own referenced
  Definition (like PACKET, but passive). Reusable, self-documenting; more objects.
- **C — PACKET-adjacent metadata.** Rejected-by-default: the Brief says do **not**
  force traits into PACKET merely because PACKET exists.
- **D — A distinct owned capability layer.** A new sibling to PACKET for
  always-true relationships. Cleanest ontology; largest new surface.

*Note:* whichever wins, **Reach** stops being a Role and becomes a trait/PACKET
property (already migrated, D·4).

**RULING:** ⬚ *unsigned.*

---

## E·tool-vocabulary
**Question.** Tool = "how Force is delivered" is signed, but its **values** are
not. What is the controlled Tool vocabulary — universal, or per-module?

- **A — Per-module only.** The Kernel defines Tool abstractly; Combat declares its
  own set later. Maximally flexible; no shared Tool language across modules.
- **B — A small universal spine + module extensions.** e.g. a few cross-domain
  Tool families every module specializes. Shared vocabulary; risk of forcing a
  fit.
- **Do not** auto-restore `Melee · Ranged · Utility` — Utility is now a Role, and
  melee/ranged may be PACKET properties rather than Tools.

*Blocks:* the Archetype formula `Role + Tool + signature`, and any card binding
that prints a Tool.

**RULING:** ⬚ *unsigned.*

---

## E·temperament-vocabulary
**Question.** Temperament (preferred application of Force) is signed as a concept;
the **exact list** and its **behavioural consequences** are not.

- Candidate list to review (not copy): `Cowardly · Resolute · Aggressive ·
  Protective · Ravenous`.
- Each needs a rebuilt definition around *preferred application of Force*, plus its
  **leaderless** behaviour and its **break/Rout** behaviour — reviewed, not
  inherited from the archived tables.

*Depends on / blocks:* interlocks with **E·combat-aftermath** (Rout uses
Temperament).

**RULING:** ⬚ *unsigned.*

---

## E·force-ontology
**Question.** Force is the unifying substrate — but *what kind of thing* is it?

- **A — A formal Kernel primitive** (a fifth first-class citizen). Strong
  unification; risks pressure to give it a number (the Brief forbids a Force stat
  unless explicitly instructed).
- **B — A defined relationship among existing primitives** (Position, State,
  Resource, agents). No new primitive; Force is a derived concept.
- **C — A conceptual lens** used by Role/Tempo/Tool/Temperament, with no mechanical
  object at all. Lightest; leans on the four axes to carry it.

*Constraint:* no numerical Force stat under any option unless a later instruction
grants one.

**RULING:** ⬚ *unsigned.*

---

## E·packet-classification
**Question.** A separate classification / retrieval registry for PACKETs is
wanted (so neutral IDs stay neutral while tooling can still index them). Its
schema, suffixes, and categories are undesigned.

- Open sub-questions: what dimensions (kind, verb-affinity, module, tags)? one
  registry or per-module? how does a tool retrieve "all melee packets" without
  re-typing the ID?
- **Constraint:** the PACKET's **primary ID stays neutral** (`spear_thrust`);
  classification lives **outside** it. Do not invent the schema early.

**RULING:** ⬚ *unsigned.*

---

## E·combat-aftermath
**Question.** The post-hit procedures are contradictory across archived drafts and
must be reconciled before signing: **Counter · Nerve · Shaken · Rout · Squelch ·
Wild · Rally**, plus the **Creature-Type** branches and the **Disengage** free
swing.

- Needs a single written ordering for: does a killed figure still Counter? once
  per round vs. Counter X? what suppresses Counter? Nerve trigger + resolver;
  Shaken vs. Rout thresholds; how Temperament directs a Rout; which Creature Types
  never test / never break / can be mended.
- **Constraint:** do not copy one archived version in; reconcile them.

*Depends on:* **E·temperament-vocabulary**.

**RULING:** ⬚ *unsigned.*

---

## E·base-millimetres
**Question.** The base vocabulary (shape=type, size=class, elongated=mounted) is
sound; the exact **round and oval millimetre standards** (B·1 table) are
provisional.

- Confirm or revise: Small/Normal/Mounted/Large/Monstrous footprints for Square
  and Circle; the oval standards for mounted/monster heroes.

**RULING:** ⬚ *unsigned.*

---

### How to sign
1. Pick an option (or write a new one).
2. Record it on the RULING line here.
3. Move the decision into the cited section of **A** (Constitution), **B**
   (Combat), or **C** (Dictionary), marking it **SIGNED** with the date.
4. Strike the entry from the status board.
