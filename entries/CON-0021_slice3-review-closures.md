# CON-0021 — Slice 3 review closures

Resolutions to the Slice 3 review, which found two hard contradictions with Slice 1 and several
ownership/lifecycle gaps. Ruled by William, 2026-07-29. These refine CON-0018…0020; the frozen First
Corpus is untouched.

## The two blockers

### (a) The history-flag pattern — Transitions stay ephemeral
- **Problem:** Slice 3 had the Aftermath "read a Transition the battle recorded," but Slice 1 defines a Transition as an ephemeral moment, not a stored object — it cannot be queried later.
- **Ruling:** A Transition stays ephemeral (a Trigger observes it *as it happens*). If a **later** Procedure needs to know it occurred, the **emitting Procedure also writes a scoped history flag** — ordinary stored State (`was_felled`, `was_broken`), owned where the changed State is owned, expiring with its scope. The Aftermath reads the **flags**, not Transitions; the reset clears them after. **Two owned flags, not an event log.**
- **Destination:** slice-1 02_WORLD (Transitions: "ephemeral vs recorded"); slice-3 00/01/04.

### (b) The `table` resolution mode — the Aftermath resolver is now defined
- **Problem:** the Aftermath used "1d6 ± care → band," which is **not** the `graded` (success-count) resolver, yet the text claimed "it's just the Slice 1 grammar."
- **Ruling (Option A — extend the grammar):** a PACKET is `automatic` (no roll) or **uncertain**; an uncertain packet declares its **resolver** — `graded` (count successes → Grade) or **`table`** (a modified single roll → result band → Effect). `table` is a first-class third mode; campaign / injury / scatter / exploration tables all use it. Aftermath packets declare `resolution: "table"`.
- (Option B — recompiling tables into dice-pools — was rejected: it warps the probability shape and reads worse for tables.)
- **Destination:** slice-1 03_GRAMMAR (`table` mode); slice-3 01 (aftermath packets).

## The refinements

- **`advance_rule` — scope was over-claiming.** Scope answers *which temporal domain owns this State*, not *how it expires*. New two-part constitutional rule: **every State declares its `scope`; every non-`permanent` State also declares an owned `advance_rule`** (heal / clear / harden / reset). Slice-3 00; shown on Injury/Rattle in 01/03.
- **Battle-Start Procedure — the missing entrance boundary.** Durable State does not apply itself. Added **Battle-Start**, the owned twin of the Aftermath: defaults → read durable State → apply each condition's initialization effect → deploy. The loop now owns *both* crossings: `Battle-Start: durable → battle` and `Aftermath: battle → durable`. Slice-3 00; owned in 03/04.
- **Roster membership is a Relationship.** "S1 belongs to Caravan A" is a fact **between** two Entities → a `caravan_membership` **Relationship** ([Slice 1 · Relationship]). The Caravan **queries** its members; it keeps no duplicate authoritative list (no two-owner violation). Same pattern retro-applies to Formation coherency. Slice-3 02.
- **"Formation with campaign scope" reworded.** Scope is on State, not on Entity kind. A Caravan uses the **same containment pattern** as a Formation, but its membership persists at `campaign` scope. Slice-3 02.
- **Eligibility unified.** Both channels key on **was-felled / was-broken** (the flags), not end-state — consistent, and correct if later content adds in-battle recovery. Slice-3 00/01.
- **Capacity made executable.** Concrete slot model (walking slots + scarce **bed slots**); the walkthrough now resolves a real **forced choice** (1 bed, 2 bed-cases → carry one, the other is lost — a death by decision). Slice-3 02/04.

## Status after closure
All ten of the review's line items resolved. The two "BROKEN" blockers (Transition retrieval,
Aftermath resolver) are closed at the grammar/object-model level, so the fix generalizes beyond
Slice 3. The architecture never failed; the seams now have names and owners.
