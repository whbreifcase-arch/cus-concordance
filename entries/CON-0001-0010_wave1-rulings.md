# Wave 1 Rulings — CON-0001 … CON-0010

Signed decisions on the ten cross-document contradiction candidates raised in
[../inventories/CONTRADICTION_REGISTER.md](../inventories/CONTRADICTION_REGISTER.md).
Ruled by William, 2026-07-28. These are Concordance rulings — they do **not** edit the frozen
First Corpus; they direct the Second Corpus rebuild.

Line refs are to `cus-kernel-rebuild` @ `first-corpus-v0.6` (`ea79b70`).

---

## CON-0001 — Nerve: the deleted 3-dice test is still live
**Disposition:** RESOLVED · **Side B is canon.**
- **Ruling:** Nerve is a **tiered save** ("psychic armour"), rolled per incoming Morale point, as in B·664 and C·453. The old **3-dice Nerve test is SUPERSEDED**.
- **Loses force:** D·118 (3-dice test presented as SIGNED) and H·161 (aftermath built on the "same three-dice, count-successes shape (B·10)") — both now cite a mechanism that no longer exists.
- **Destination:** Second Corpus / Combat (Nerve save) + Persistence (rewrite Care/Nerve checks onto the tiered save).
- **Confirmed (William, 2026-07-28):** Nerve tier scales with the unit the way Armour does (tougher unit → higher Nerve tier), using the same save roll as Armour.

## CON-0002 — AP on the laminated reference sheet
**Disposition:** RESOLVED · **Side B is canon.**
- **Ruling:** **Square = 2 AP, Circle = 3 AP** is standard. J·78 and B·839 are correct; **E·207 "AP = 3" is struck drift** (E·392 already agrees).
- **Exceptions:** allowed only as a **named, owned field** (per Kernel Law 15) — never a prose special-case. Default is 2 / 3.
- **Destination:** Second Corpus foundation (Agency) + Component/reference-sheet spec.

## CON-0003 — Spray falloff
**Disposition:** RESOLVED · **Side B is canon.**
- **Ruling:** Spray is a **full roll per hop, costing 1 Charge** (K·123, E·347). The **"−1 die per hop" falloff is SUPERSEDED**.
- **Loses force:** C·469 (the Dictionary) and G·804 — highest-leverage fix, since every module checks its words against C.
- **Destination:** Second Corpus / Firearms; correct the Dictionary entry.

## CON-0004 — "Charge" means two different things
**Disposition:** RESOLVED (revised 2026-07-28).
- **Ruling:** **"Charge" is the finite Resource** — it "remains what it is" (the 🟡 finite kind; skins Ammo / Arrows / Mana). The **movement "charge" is not a defined term**: a qualified Sprint is an **emergent action**, not a primitive; if it needs a label at all, call it **"surge."**
- **Loses force:** the B / F / G framing of "Charge = a Sprint that qualified" as a named thing — demoted to emergent movement (optional label *surge*). Only one concept keeps the name **Charge** (the Resource), which resolves the collision.
- **Destination:** Second Corpus / Firearms + Dictionary (one entry for Charge = Resource); Combat notes the surge as emergent, undefined.

## CON-0005 — Persistence: module or Kernel architecture?
**Disposition:** RESOLVED · **Side A is canon.**
- **Ruling:** **Persistence is Kernel architecture, not a module** (H·15, E·135). The "module" framing in C·285, E·117, and H §10 is **SUPERSEDED** — it was an unfinished intent ("meant to write Persistence into the kernel and forgot").
- **Destination:** Second Corpus foundation — write Persistence into the kernel spec; H remains a holding pen until absorbed; "do not cite H as a domain" holds.

## CON-0006 — Champion wounds on a "stateless" card
**Disposition:** RESOLVED · **Side A (J) is canon.**
- **Ruling:** The card **stays stateless** (J·64). Champion wounds are tracked by **physical tokens beside the model** — subtractive, and only ever 2–3 Circles on the table, so the load is trivial. **E·245 ("wound track on the Champion card") is SUPERSEDED.**
- **Destination:** Second Corpus / Component Layer (token spec for Circles).

## CON-0007 — Morale: spendable Resource vs State
**Disposition:** RESOLVED · **Side B is canon.**
- **Ruling:** **Morale is State** (damage on a State track), **not a Resource**. Remove Morale from the Resource enumeration (C·50, and the inherited A Resource list).
- **Destination:** Second Corpus foundation (State vs Resource) + Dictionary.

## CON-0008 — "Standing": Position fact vs Caravan resource
**Disposition:** RESOLVED · **remnant dropped (2026-07-28).**
- **Ruling:** The **Caravan-level "Standing" resource (H·336) is a stale remnant — dropped.** It is not carried into the Second Corpus. If "Standing" appears at all, it is the unquantified **Position fact** framing (I·233, "not a meter, no stat"), which imposes no mechanic.
- **Destination:** Second Corpus — do not implement a Standing resource; Dictionary marks the Caravan "Standing" resource `REJECTED` (remnant).

## CON-0009 — Who owns Rally — a leader, or the Sergeant?
**Disposition:** RESOLVED · **a leader can Rally.**
- **Ruling:** **A leader can Rally — that is the point of a leader.** The Sergeant supplies it too (C·275). **H·212 ("a leader cannot Rally") is STRUCK.**
- **Destination:** Second Corpus / Combat (Rally owned by leaders; Sergeant as a leader node); Dictionary strikes the H·212 line.

## CON-0010 — Can a Circle break?
**Disposition:** RESOLVED · **Side B is canon (rule removed).**
- **Ruling:** **Circles can break.** Break is tracked on its **own separate meter**, distinct from a Square's Nerve. **B·41 "never tests Nerve, never breaks" is SUPERSEDED** (the "never breaks" clause is removed; a Circle still has no facing).
- **Interacts with CON-0001:** the Circle break meter is *not* the tiered Nerve save — it is its own meter.
- **Destination:** Second Corpus / Combat (Circle break meter).

---

## Summary

| Case | Verdict | Disposition |
|---|---|---|
| CON-0001 Nerve | Real | RESOLVED — tiered save; 3-dice test superseded (confirmed) |
| CON-0002 AP sheet | Real | RESOLVED — 2/3 standard; exceptions as named fields |
| CON-0003 Spray | Real | RESOLVED — full roll + 1 Charge |
| CON-0004 "Charge" | Real | RESOLVED — Charge = Resource; movement is emergent ("surge") |
| CON-0005 Persistence | Real | RESOLVED — Kernel architecture, not a module |
| CON-0006 Champion wounds | Real | RESOLVED — stateless card; tokens beside model |
| CON-0007 Morale | Real | RESOLVED — State, not Resource |
| CON-0008 Standing | Real | RESOLVED — remnant dropped |
| CON-0009 Rally | Real | RESOLVED — a leader can Rally; H·212 struck |
| CON-0010 Circle break | Real | RESOLVED — Circles break on own meter |

**All 10 resolved. Next step: Wave 2 (ontology · dependency · layering) — launched.**
