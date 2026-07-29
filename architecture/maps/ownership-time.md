Both tables below cover the fact/state-bearing concepts in the catalog (primitives/definitions that hold no runtime state, e.g. `provokes`, Reach, Tempo, are omitted from TIME and appear in OWNERSHIP only where an authority question exists). Labels: [S]=SOURCE (catalog/ruling text), [I]=STRUCTURAL INFERENCE, [P]=PROPOSAL. Rulings cited as R#.

## OWNERSHIP (concept | canonical owner | duplicate / hidden-state flag)

| concept | canonical owner | duplicate / hidden-state flag |
|---|---|---|
| Position | Kernel (substrate); runtime lives in **Instance** | Clean. [S] Written by MOVE/Impact, read everywhere; not stored redundantly. |
| Force | Kernel (non-numerical primitive) | Clean — no stat, no roll, holds no state. [S] |
| SOUL | Kernel — **RESERVED / blank** | No owner-of-state because it has none; never read/changed. Not operationalized here. [S/PROTECTED] |
| Agency (AP) | Kernel; per-figure **Instance** | Clean under R2 (Square=2/Circle=3). Any AP exception must be a **named owned field** (Law 15), never prose. [S,R2] |
| State (carrier) | Kernel; stored **only in Instance** (Law 5) | Clean. [S] |
| Resource (carrier) | Kernel; Instance | **FLAG (resolved by R7):** C still enumerates Health/**Morale** as Resources — overridden; Morale is State. Do not carry the Resource framing. [S,R7] |
| Wounds / wounds_remaining | **Combat**; Instance | Clean for rank-and-file. See Champion for the token exception. [S] |
| Champion wounds | **physical tokens beside the model** (Instance), subtractive | **FLAG (resolved by R6):** J's "count may live on the card" (CONTRADICTION-01) is overridden — the card is **stateless**. Any card-as-wound-track = presentation acting as authority; forbidden. [S,R6] |
| Morale (Mind damage) | **Combat** (Mind channel) | Duplicate-ownership flag = same as Resource row: it is **State**, not a Resource (R7). [S,R7] |
| Morale track (Steady/Shaken/Broken) | **Combat** | Clean; one-way ratchet, only Rally steps up. [S] |
| Nerve | **Combat** — a tiered **SAVE** (R1) | **FLAG (rulings do NOT reconcile):** the aftermath 3-dice "Nerve check" (H/E, E-LAW-136) is a *different* owner-shape (a roll, not a save) using the same name. Two encodings of "Nerve" coexist. [S,R1] |
| Knocked Out / Dead | **Combat**; Instance | Clean; KO-vs-Dead decided by felling Effect + Creature Type. Model J encodes KO on its side — display of the same fact, not a second owner. [S] |
| Charge (Resource) | Kernel primitive; per-weapon **Instance** | Clean under R4 — **only** the Resource is named Charge; the movement "Charge" is emergent, not a state owner. [S,R4] |
| Strain | Kernel primitive; Instance | Clean; accumulating, caps at 3. [S] |
| Stun | **Combat** | **Hidden-state check: OK** — R/§ says it *rides the existing activation flag*, "no new marker." Steps the flag rather than holding its own state. [S] |
| Activation flag / stoplight | **Component Layer** (single owner) | **FLAG (resolved):** previously double-encoded flag+card; collapsed to one owner. Hand-thickness / card-down are *derived displays* of this flag, not independent state. Watch for re-introducing a second activation store. [S] |
| Pin | — (**struck**) | Superseded; covered by Stun (physical) + Morale (fear). Ensure no lingering "Pin" state. [S] |
| Engagement / Facing / front arc | **Combat**; read from **base geometry** | **Hidden-state check: OK** — explicitly not stored; read off the footprint each time. [S] |
| Standing | **Story** — a **Position fact** (R8) | **FLAG (resolved by R8):** the Caravan "Standing" *resource/meter* is a dropped remnant. No meter, no stat. Any code treating Standing as a quantity = duplicate ownership. Unquantified fact = mild hidden-state (no storage rule given). [S,R8] |
| Composure | **Story**; Instance | Clean; social twin of Wounds. [S] |
| Yielded / Moved | **Story**; Instance→persists | Moved persists **as a Bond** (ownership hands off to Persistence/Story-Bond). Whether an NPC Circle can be Moved is **OPEN** (I-LAW-070, Rank vs Control) — not resolved by rulings. [S] |
| Injury | **Persistence** (kernel architecture, R5) | Clean owner; note Persistence is **architecture not a module** (R5) — do not cite Doc H as a domain owner. [S,R5] |
| Scar | **Persistence** | Clean; MIND scars are Written Triggers. Some BODY scars only subtract (H self-flags vs "takes and gives") — unreconciled by rulings. [S] |
| hollow | **Persistence** (owner-held) | Hidden-mechanic by design: "how a figure becomes hollow is deliberately unpublished." Owner named; trigger intentionally withheld. [S] |
| Bond | **Persistence/Story** | **Hidden/OPEN:** directed-vs-mutual is ⚠ OPEN; storage shape unspecified. [S] |
| Neglected / Recovery counter | **Persistence** | Clean; ticks only when tended. [S] |
| Advancement / Ruin | **Persistence** | Ruin "largely unwritten" — **STUB**, owner named but procedure absent. [S] |
| Progression (where it lives) | **Figure's Instance** (R8) | **FLAG (resolved by R8):** "progression lives in the Caravan" is **struck**. Caravan is a physical entity, not the state home. [S,R8] |
| Mission | **Kernel** (AI object, Law 9 AI-only) | Can override Doctrine — clear hierarchy, no duplicate authority. [S] |
| Doctrine | **Combat/AI layer** (non-axis) | Clean; explicitly NOT a fifth Kernel axis; Mission-overridable default. [S] |
| Spawn pool / Nest / The clock (Time) | **Doc L (Horde)** | Clean; fills the reserved F_AI_DIRECTOR slot. [S] |
| Card / reference sheet | **Component Layer** — Capability only, **no runtime state** (Law 5) | Presentation-as-authority guardrail: enforced by R6 (Champion). Card must never become a state owner. [S,R6] |
| Hand / status display | **Component Layer** — display only | "A status display, not a deck." Reflects activation state; not an owner. [S] |
| Reaction pool | — (**struck** 2026-07-27) | Jobs redistributed to **three distinct owners**: cap→front arc, authoring→`provokes`, anti-milking→once-per-occurrence. No orphaned state. [S] |
| Push vs Shove | Push→**charge plow (Combat B·4)**; Shove→**weapon Effect (B·9b)** | **FLAG (rulings do NOT cover):** C-LAW-C01 name collision; two owners, resolved only by convention ("Push"=plow only). [S] |

## TIME (state | scope | has-expiry? | risk)

| state | temporal scope | has explicit expiry/reset? | risk |
|---|---|---|---|
| Agency (AP) | activation | **Yes** — refreshes on activation | LOW [S] |
| Armed WAIT / Overwatch | activation | **Yes** — expires on figure's next activation | LOW [S] |
| Brace | activation | **Partial** — ends activation / broken by Shove; facing-lock duration only implicit | MED [I] |
| Stun | activation | **Yes** — recovers next activation | LOW [S] |
| Activation flag + "activated" mark (Form Up) | round | **Yes** — START OF ROUND resets eligibility | LOW [S] |
| Wounds / wounds_remaining (incl. Champion tokens) | battle | **No explicit** — labelled "transient (Combat)" but no stated restore-to-max at battle start | MED [S/I] — flag |
| Morale (Mind damage) + Morale track | battle | **Partial** — Rally steps up **in-battle only**; NO between-battle reset rule stated | **HIGH** [S] — flag; one-way ratchet with no cross-battle clear |
| Composure | scene | **Yes** — refreshes at scene end | LOW [S] |
| Yielded (concession) | > scene, unstated | **No** — "concession stands"; end-scope (session? campaign?) undefined | MED [S] — flag |
| Moved | campaign+ (persists as Bond) | **No** (by design) — inherits Bond's (missing) rule | see Bond |
| Charge (Resource) | action/activation | **Partial** — Reload/card-down restores in-battle; NO between-battle replenish rule | MED [S] — flag |
| Strain | activation/round | **Partial** — VENT at 3; no periodic reset; between-battle carry unstated | MED [S] — flag |
| Misfire / Overheat (gun offline) | activation | **Yes** — card-down, cleared by a reload activation | LOW [S] |
| Injury | campaign (Period clock) | **Yes** — recovery counter, ticks only in a tended period | LOW [S] |
| Neglected / Recovery counter | campaign | **Yes** — per tended Period | LOW [S] |
| Scar | history / generation | **No — by design** (permanent; Redemption deliberately absent) | LOW-by-design [S] |
| hollow | history (permanent, deepens) | **No** + **UNBOUNDED** Nerve decay (no floor) | **HIGH** [S] — flag: unbounded growth, no cap/reset |
| Bond | campaign / generation | **No** decay or expiry rule; directed-vs-mutual OPEN | MED [S] — flag |
| Grudge (Written Trigger) | history+ | **No — by design** (= MIND scar, permanent) | LOW-by-design [S] |
| Vow (WAIT armed cross-scene) | until trigger fires | **No** — combat WAIT's "expires next activation" does not obviously apply; an **unfired** Vow has no stated expiry | MED [I] — flag |
| Standing (Position fact) | unstated | **No** — no meter, no reset; unquantified | MED [S] — flag (per R8, kept a fact not a meter) |
| Mission | mission | **Yes (implied)** — ends with the mission | LOW [I] |
| Doctrine | battle default | N/A — persistent default, Mission-overridable | LOW [S] |
| Spawn pool | battle / scenario | **Yes** — nest death (ENDLESS) or FINITE N depletion | LOW [S] |
| The clock (Time) | battle / scenario | **Yes** — run-out = loss condition | LOW [S] |
| Nest (health / Position / count) | battle | **Yes** — killed to stop flow; count-past-containment = loss | LOW [S] |
| Advancement | campaign / generation | **No — by design** (accrues) | LOW-by-design [S] |
| Ruin | on Caravan destruction | **STUB** — largely unwritten | flag [S] |
| Period | campaign clock unit | **STUB** — "1 battle = 1 period" placeholder; real seasons/travel clock pending | flag [S] |
| Information (Resource) | scene / story | **No** — resolved as a PACKET Effect; persistence/expiry unstated | MED [I] — flag |
| reloading Written Trigger | per-occurrence | **Yes** — fires once per occurrence | LOW [S] |
| Counter | instant | **Yes** — once per occurrence; no lingering state | LOW [S] |
| SOUL | — | N/A — never read/valued/triggered; no temporal scope | N/A / PROTECTED — not operationalized [S] |

### Cross-cutting flags

- **Highest TIME risks (state with no reset rule):** (1) **Morale/Morale track** — no between-battle clear stated [S]; (2) **hollow** — unbounded, unfloored Nerve decay [S]; (3) **unfired Vow** — no expiry, and the combat-WAIT expiry rule doesn't cleanly reach cross-scene Vows [I].
- **Battle→battle boundary is under-specified generally:** Wounds, Morale, Charge, and Strain all lack an explicit at-battle-end reset/replenish rule. Attrition is a stated *design principle*, but the reset semantics per resource are not individually written [S/I]. Recommend one owned per-resource "battle-end disposition" field.
- **Rulings-uncovered contradictions that also carry temporal/ownership ambiguity (respected, not resolved):** Nerve-as-save vs 3-dice aftermath "Nerve check" (E-LAW-136); Push/Shove name split (C-LAW-C01); NPC-Circle Moved eligibility (I-LAW-070); Bond directed-vs-mutual (⚠ OPEN).
- **Presentation-as-authority guardrails, all currently respected by the rulings:** Champion wounds on tokens not the card (R6); Standing a Position fact not a meter (R8); Morale State not Resource (R7); Card holds no runtime state (Law 5). Flag any implementation that migrates these back onto a card/meter.
- **SOUL:** recorded RESERVED/blank in both tables; no owner-of-state, no temporal scope, no mechanic — not operationalized.
