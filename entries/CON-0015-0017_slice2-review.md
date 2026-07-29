# CON-0015 … CON-0017 — Slice 2 review resolutions

Three foundation decisions that came out of the Slice 2 review (which found the prose claiming more
closure than the rules had earned). Ruled by William, 2026-07-28. All flow **back into the Slice 1
foundation** — they are not Slice-2-local. Concordance rulings; the frozen First Corpus is untouched.

> Note: the review's "required fix #2" (a Circle's break has no owned runtime state) was **already
> resolved** by the CON-0010 revision — a Circle now breaks through the standard Mind channel, whose
> state is ordinary State at *(Circle, Instance)*. The review predated that change.

---

## CON-0015 — Resolution modes: everything resolves through a PACKET
**Disposition:** RESOLVED · foundation (Slice 1 · 03_GRAMMAR).
- **Problem:** Rally was written as an ACTION that directly stepped the Mind track — a second, dice-less execution path outside the PACKET grammar. That would let capabilities quietly bypass the grammar.
- **Ruling:** **Every capability resolves through a PACKET — no stray Procedures.** A packet declares a **`resolution` mode**:
  - **`graded`** — roll → Success → Grade → Effect (the Slice 1 default; anything with uncertainty).
  - **`automatic`** — applies its Effect with **no roll and no Grade**; still targets, checks constraints, and costs Agency.
- **Rally is an `automatic` packet** (`recover 1 Morale stage`). Automatic and graded are the **same grammar with the dice step optional**, not two engines. A normally-automatic effect may be given a **graded** version for drama (a graded Rally/heal whose Grade decides how much).
- **Generalises to:** heal, open a door, issue a command, interact with an object — all `automatic` packets.
- **Destination:** Second Corpus / slice-1 03_GRAMMAR (the `resolution` field + both modes); slice-2 03_THE_GROUP (the `rally` packet).

## CON-0016 — The activation scheduler
**Disposition:** RESOLVED · foundation (also underpins Slice 1, which had quietly assumed it).
- **Problem:** the corpus never defined turn order; whether a broken figure Routs *before* its leader can Rally was undecidable.
- **Ruling:** **Alternating activation, one figure at a time.** Within a **round**, sides alternate; on your turn you activate exactly one un-activated figure (spending its Agency on MOVE/ACTION/WAIT); then the opponent activates one; repeat until all have activated; the round resets. **One activation per figure per round.**
- **Formation MOVE has no separate activation:** a member declares it on its own activation; it and each coherent member **that has not yet activated this round** move together, each spending **1 AP**, and **that move is each mover's activation for the round.** The whole coordinated move counts as **one** activation in the alternation. This preserves Slice 1's "Agency only on your own activation" (each mover is activating now) and "one activation per figure per round."
- A **Circle never joins a Formation MOVE** (Ruling 13); it takes its own activation on its 3 AP.
- **Why alternating:** it makes tempo a decision — a routing figure can act before its leader reaches it, so holding the line *costs a turn*.
- **Destination:** Second Corpus / slice-2 00_ACTIVATION (new foundation doc).

## CON-0017 — The Transition boundary (how Triggers observe change)
**Disposition:** RESOLVED · foundation (Slice 1 · 02_WORLD).
- **Problem:** Shock was described as "a Written Trigger carried by the *felling event*" — but Event is not an object in the model. It smuggled in an object-like concept.
- **Ruling:** No Event object. Four distinct terms cover all causal propagation:
  - **State** — what is true (one Instance cell).
  - **Transition** — the fact that a State just changed; **emitted by the Procedure that owns the changed State** (the Body procedure emits `felled` when it writes a figure to Knocked Out/Dead). A named moment, not a stored object.
  - **Trigger** — a clause on a Definition that watches a named Transition (a Written Trigger).
  - **Invocation** — the Trigger fires and invokes a PACKET (free, once per occurrence, gated by Position + authoring).
- Causal chains are: **Procedure writes State → emits Transition → Trigger invokes PACKET → Effect writes State → next Transition.** Every step owned; no Entity skipped.
- **Destination:** Second Corpus / slice-1 02_WORLD (new "Transitions" section); slice-2 01_MIND_CHANNEL (Shock re-owned onto the `felled` Transition).

---

## Minor corrections applied alongside (no separate CON)
- **"MOVE-class" was illegal vocabulary** — there are three verbs. Form Up is now "a MOVE that ends in a legal Formation relationship."
- **"one-way ratchet"** contradicted Rally → "steps down on unsaved Morale; only Rally steps up in-battle; no passive recovery."
- **"symmetric twin"** → "the same channel *interface*" (interface symmetric; tracks — depth vs stages — deliberately not).
- **Formation screen geometry** given a named predicate `flank_covered(figure, side)` (coherent, unbroken, same-Formation neighbour in base contact overlapping the flank arc).
- **Walkthrough** rewritten on the real scheduler so **S2 actually performs a Rout** (a full fleeing activation, leaving the Formation) *before* being Rallied — the loop is now exercised, not asserted.
