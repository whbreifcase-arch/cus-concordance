# CON-0014 — The Object Model: one root noun, three orthogonal axes

**Disposition:** RESOLVED · ratified 2026-07-28 (William).
Foundational ontology decision for the Second Corpus. Refines — and supersedes the looser framing
of — Architecture Zero §1 ("what exists"), which listed ~13 flat categories. Recorded here because
ontology is the hardest thing to change later.

## Problem
The first draft of `02_WORLD.md` made **Entity** the universal noun, then had to patch "a PACKET is
an object too / a Relationship is an object too." Entity is not universal — it is one kind. The
corpus lacked a single root noun.

## Ruling
**Everything that exists in CUS is an Object.** Object is the root; it specializes:

```
Object ── Entity (Figure · Formation · Caravan · Kingdom · Nest · …) · Packet · Relationship
```

Every Object is described by **three orthogonal, non-overlapping axes**:

1. **Ontology** — *what is it?* → Object → Entity / Packet / Relationship.
2. **Layer** — *where does it exist?* → Definition · Procedure · Instance · Presentation. A layer is a **perspective**, not a thing; an Object may be empty at some layers (a Packet's Instance facet is always empty).
3. **Ownership** — *who is authoritative for a fact?* → exactly one **(Object × Layer)** cell. Ownership is a **coordinate, not a column**: it is the rule that Axis 1 × Axis 2 has one authoritative cell per fact. **Presentation owns nothing — it mirrors.**

## Why the three axes matter
They do not overlap, and most First-Corpus contradictions came from tangling two of them (e.g.
putting runtime state in a Definition, or a second authoritative copy on a card). Separating them
makes every new mechanic answer three independent questions instead of one mushy one.

## Root-word choice
**Object** (not Thing / Node / Construct / Element). What CUS describes is literally an object graph
(nodes + references + single-owner facts); "Node" undersells ownership, "Thing" undersells
structure. Recorded so the choice isn't relitigated casually.

## Information preserved
Entity, Packet, Relationship, the four layers, and the one-owner law all survive — they are now
correctly located as *specializations* and *axes* under a single root, rather than as peers.

## Information rejected
Entity-as-universal-noun. The "a PACKET is an object too" phrasing.

## Destination
- Second Corpus: `slice-1/02_WORLD.md` (rewritten to this model); light ripples in `01_PRIMITIVES.md`, `03_GRAMMAR.md`, `slice-1/README.md`.
- Architecture Zero §1 to be reconciled to this ontology on its next revision (its category list becomes a view of Axis 1, not a competing taxonomy).

## Open risks
- Whether **Procedure** is best modelled as a pure layer (a facet/method of Objects) or eventually needs first-class object status for owned resolvers. Carried as PROVISIONAL; Slice 1 does not force it.
