# CON-0018 … CON-0020 — Slice 3: Persistence

The Slice 3 (full persistence) architecture decisions. Ruled by William, 2026-07-28. These build out
**CON-0005** (Persistence is Kernel architecture, not a module) into a concrete, object-model-native
campaign layer. Concordance rulings; the frozen First Corpus is untouched.

---

## CON-0018 — Persistence = temporal scope on State + the Aftermath
**Disposition:** RESOLVED · foundation. Discharges CON-0005.
- **Ruling:** Persistence owns **no mechanic of its own**. It is two things already latent in the object model:
  1. **Temporal `scope` on every State** — `instant · activation · round · battle · campaign · permanent`. Scope says *when a fact resets*. This also closes the Wave-2 "state without an expiry rule" risk: every State now declares its scope.
  2. The **battle-end reset** wipes all `battle`-scoped State; `campaign`/`permanent` State survives — that surviving remainder *is* the persistent record.
- The one Procedure Persistence adds is the **Aftermath**, at the battle→campaign boundary: it reads the battle's **Transitions** (`felled`, `broke`), resolves a graded packet per marked figure, and **promotes** the result to `campaign`/`permanent` State *before* the reset.
- **Why not a module:** a module owns mechanics; Persistence owns a *rule about State* that sits **under** every module. "Do not cite Persistence as a domain — cite the scope."
- **Destination:** slice-3 00_PERSISTENCE.

## CON-0019 — The harm lifecycle
**Disposition:** RESOLVED · content structure ratified; numbers ⚠ PROVISIONAL.
- **Both channels share one shape:** `battle harm → Aftermath roll → durable mark`, and both Aftermath rolls are **graded PACKETs** (no new engine).
  - **Body:** Wound (battle) → Body Aftermath (on `felled`) → **Injury** (`campaign`; heals or hardens) → **Scar** (`permanent`). Worst result = **Dead** (`permanent`, removed from roster).
  - **Mind:** Morale (battle) → **the Morale check** (Ruling 11; on the **`broke` Transition**, *not* end-state — a rallied figure still broke) → **Rattle** (`campaign`) → **Mind Scar** (`permanent`).
- **Death is real and permanent** — the stake that makes Injuries/Scars matter as the *survivable* outcomes.
- **Care** modifies rolls (a Healer facility, safe ground: +1; abandoned/isolated: −1).
- **Protected:** the lifecycle **stops at Scar** and never reads/writes/defines **SOUL**. **Redemption** and going **hollow** are recorded as **declared blanks** and left unbuilt (Appendix Ω discipline).
- **Destination:** slice-3 01_HARM_LIFECYCLE.

## CON-0020 — The Caravan and the campaign loop
**Disposition:** RESOLVED · foundation for the campaign layer.
- **The Caravan is an Entity** that *contains* the roster between battles — the **same nesting rule as a Formation, at `campaign` scope.** Ontology payoff: *a campaign roster is a Formation grown up.* No new Object kind. It has **capacity** (the wounded cost more — a real choice) and **facilities** (referenced Definitions that modify campaign Procedures; e.g. the **Healer**, `+1 care` and faster healing). It is a physical model on the table; its ledger lives in the companion app.
- **The campaign loop is the decision loop recursed (Law 4):** `Battle → Aftermath → March → next Battle`, with the **Caravan as the acting Entity** and the **map as its Position**.
- **The clock** is the `campaign` scope made countable. A **March** advances it: Injuries heal or harden, Rattle clears, `Charge` replenishes, Scars never move. **Rest vs hurry** (heal a step vs keep tempo) is the campaign's core decision.
- **History feeds forward:** the next battle instantiates each figure **with its durable State intact** — a Scarred figure carries its hook, an Injured figure fights impaired, the Dead are absent. "A battle makes history" = the State that refused to reset walks into the next fight.
- **Destination:** slice-3 02_THE_CARAVAN, 03_THE_CAMPAIGN_LOOP.

---

## The Slice 3 object-model result
No new Object kind was needed for "campaign." It decomposed into: **scope** (a field on State) +
**Aftermath** (a Procedure) + **Caravan** (an Entity, = Formation at campaign scope) + **clock** (the
`campaign` scope, countable). The three-axis ontology held at the top of the stack — the real test of
the slice.
