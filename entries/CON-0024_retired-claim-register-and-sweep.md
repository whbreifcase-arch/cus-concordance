# CON-0024 — Retired-claim register and consistency sweep

**Disposition:** RESOLVED · ratified 2026-07-29 (William).
This ruling establishes a **governance mechanism**, not new architecture. It exists because the
retired-claim register (`_retired/`) and the repeatable sweep create a new practice for controlling
vocabulary drift. It records the specific consistency pass applied after CON-0023.

## Ratifies
- **`_retired/registry.tsv`** as the single index of **retired claims** — each a contextual pattern that identifies a *retired semantic claim*, never a banned word.
- **Every register entry must cite an authoritative ruling.** The register **owns no mechanic or interpretation independently**; where a register row and its cited ruling disagree, **the ruling wins.**
- **`_retired/sweep.py`** reads the register and scans the canonical Second-Corpus docs; **any unallowed match fails the sweep** (nonzero exit).
- **Historical callbacks in canon require an explicit inline allowance** — `<!-- retired-lint: allow <id> reason: … -->` on the matching line or the one above (no line-number allowlists; allowances survive editing). Every exception is thus a *named, visible field*.
- **Cleanup propagation does not alter the rulings it propagates.** Wording is brought into line with existing rulings; the rulings themselves are untouched.

## Records
- The **post-CON-0023 consistency propagation pass** (the ten review items: Archetype removed from the authoritative Unit Profile; field groups not "layers"; ownership reserved to `(Object × Layer)` cells; composition *fields* not "primitives"; Signature *specializes* not "resolves"; legal HEAL card grammar; sockets/keyed-geometry returned to PROVISIONAL, no Reaction/Support category; Doctrine split; Scar as Figure State; `book_membership` in the walkthrough; Slice 3 claims corrected; interface authority wording; stale root-README line).
- The Second Corpus commit that performed it: **`cus-second-corpus@3e60b88`** ("Consistency propagation (CON-0023) + retired-claim graveyard & sweep").

## Does not
- **Supersede CON-0023** (or any earlier ruling). CON-0023 governs the architecture; this governs the *drift-control mechanism*.
- **Restate the prior mechanical rulings** — each retired claim's authority remains its own ruling.
- **Turn the graveyard into an authority.** `_retired/` indexes; it never rules.

## Citation note
Second Corpus **substantive** docs (composition/interface) cite **CON-0023**. Only
`_retired/README.md` cites **CON-0024**, as the authority for the *register process*.
