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
- **⚠ Confirm:** the note "their nerve tracks to tank … same roll above to pass a nerve check" is read as *Nerve tier scales with the unit the way Armour does (tougher unit → higher Nerve tier), using the same save roll as Armour.* Confirm that reading before it's written as law.

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
**Disposition:** RESOLVED (naming split).
- **Ruling:** **"Charge" stays the movement term** — the qualified Sprint / 3″ run-up (B, F, G). The **finite Resource kind is RENAMED "Uses"** (was the 🟡 finite "Charge"; skins Ammo / Arrows / Mana).
- **⚠ Scope flag:** this changes the **Kernel Resource-kind vocabulary in A** (the three kinds become e.g. Agency / **Uses** / Strain), plus C·68 and K·182. Confirm "Uses" is the noun you want engine-wide before it propagates.
- **Destination:** Second Corpus foundation (Resource kinds) + Firearms + Dictionary.

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
**Disposition:** UNRESOLVED · **no ruling yet.**
- **Open question:** Is Standing an unquantified **Position fact** (I·233, "not a meter, no stat") or a **Caravan-level STORY resource degraded by scars** (H·336)? These are incompatible as written.
- **Needs:** your decision. (This is the only one of the ten still open.)

## CON-0009 — Who owns Rally — a leader, or the Sergeant?
**Disposition:** PROVISIONAL · **both, for now.**
- **Ruling:** Both a **leader** and the **Sergeant** may Rally, provisionally, pending play.
- **⚠ Conflict flag:** H·212 says "a **leader cannot** Rally" — that directly contradicts "both." It must be reconciled or struck before this leaves PROVISIONAL.
- **Destination:** Second Corpus / Combat (Rally ownership) — carry as PROVISIONAL.

## CON-0010 — Can a Circle break?
**Disposition:** RESOLVED · **Side B is canon (rule removed).**
- **Ruling:** **Circles can break.** Break is tracked on its **own separate meter**, distinct from a Square's Nerve. **B·41 "never tests Nerve, never breaks" is SUPERSEDED** (the "never breaks" clause is removed; a Circle still has no facing).
- **Interacts with CON-0001:** the Circle break meter is *not* the tiered Nerve save — it is its own meter.
- **Destination:** Second Corpus / Combat (Circle break meter).

---

## Summary

| Case | Verdict | Disposition |
|---|---|---|
| CON-0001 Nerve | Real | RESOLVED — tiered save; 3-dice test superseded ⚠confirm |
| CON-0002 AP sheet | Real | RESOLVED — 2/3 standard; exceptions as named fields |
| CON-0003 Spray | Real | RESOLVED — full roll + 1 Charge |
| CON-0004 "Charge" | Real | RESOLVED — Charge=movement; resource→"Uses" ⚠scope |
| CON-0005 Persistence | Real | RESOLVED — Kernel architecture, not a module |
| CON-0006 Champion wounds | Real | RESOLVED — stateless card; tokens beside model |
| CON-0007 Morale | Real | RESOLVED — State, not Resource |
| CON-0008 Standing | — | **UNRESOLVED — needs decision** |
| CON-0009 Rally | Real | PROVISIONAL — both, for now ⚠H·212 conflicts |
| CON-0010 Circle break | Real | RESOLVED — Circles break on own meter |

**Next step (Wave 2): not yet chosen.**
