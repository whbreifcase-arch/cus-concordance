# Wave 1 — Extraction Inventories

Raw Law + Concept inventories extracted from the **frozen First Corpus** (`cus-kernel-rebuild`
@ `first-corpus-v0.6`, commit `ea79b70`). One file per source document, plus a cross-document
contradiction register.

**Status: `EXTRACTED` — raw, unreviewed.** These are archaeology, not canon. Nothing here is a
ruling. Every row is labelled `SOURCE` / `DIRECT INFERENCE` / `STRUCTURAL INFERENCE` / `PROPOSAL`
/ `UNRESOLVED` / `CONTRADICTION`; `SOURCE` rows carry a verbatim quote + line number. Contradictions
were *raised, never resolved* — resolution is a later, signed step (a `CON-####` entry).

## Files

| File | Source document |
|---|---|
| [A_KERNEL_CONSTITUTION.inventory.md](A_KERNEL_CONSTITUTION.inventory.md) | A — Kernel Constitution (95 laws · 60 concepts) |
| [B_COMBAT_MODULE.inventory.md](B_COMBAT_MODULE.inventory.md) | B — Combat Module |
| [C_KERNEL_DICTIONARY.inventory.md](C_KERNEL_DICTIONARY.inventory.md) | C — Kernel Dictionary |
| [D_MIGRATION_MAP.inventory.md](D_MIGRATION_MAP.inventory.md) | D — Migration Map |
| [E_OPEN_DECISIONS.inventory.md](E_OPEN_DECISIONS.inventory.md) | E — Decision Register |
| [F_CLASH_RESOLUTION.inventory.md](F_CLASH_RESOLUTION.inventory.md) | F — Continuous Clash Resolution |
| [G_WHY_NOT.inventory.md](G_WHY_NOT.inventory.md) | G — Why Not (rationale register) |
| [H_PERSISTENCE.inventory.md](H_PERSISTENCE.inventory.md) | H — Persistence (holding pen) |
| [I_STORY.inventory.md](I_STORY.inventory.md) | I — Story (proposed) |
| [J_COMPONENTS.inventory.md](J_COMPONENTS.inventory.md) | J — Component Layer |
| [K_FIREARMS.inventory.md](K_FIREARMS.inventory.md) | K — Firearms & Ranged Warfare |
| [L_HORDE_AND_CAMPAIGN.inventory.md](L_HORDE_AND_CAMPAIGN.inventory.md) | L — Horde & Campaign |
| [M_SCIFI_SETTING.inventory.md](M_SCIFI_SETTING.inventory.md) | M — Sci-fi Setting |
| [N_DIGEST.inventory.md](N_DIGEST.inventory.md) | N — The Digest |
| **[CONTRADICTION_REGISTER.md](CONTRADICTION_REGISTER.md)** | **Cross-document contradiction candidates (10)** |

## Method

14 archaeologist agents (one combined Law+Concept extractor per document, A–N) under a strict
discipline: do not improve wording, do not reconcile contradictions, cite or label everything,
and never propose a definition/value/trigger for the reserved SOUL primitive. Followed by one
Contradiction Hunter fed all extractor output. See the Concordance charter and status codes in
the repo root.

## The 10 cross-document contradiction candidates (headlines)

- **HIGH** CON-CAND-001 — Nerve: B & C rebuilt it as a tiered *save* and deleted the 3-dice test, but D presents the 3-dice test as SIGNED and H's whole aftermath system cites the removed B·10 shape.
- **HIGH** CON-CAND-002 — AP on the laminated reference sheet: E prints "AP = 3"; J and B print "Square 2 · Circle 3"; E later calls "AP=3" struck drift.
- **MED** CON-CAND-003 — Spray falloff: C (dictionary) & G still say "−1 die per hop"; K & E redefine it as a full roll costing 1 Charge.
- **MED** CON-CAND-004 — "Charge" names two live concepts: the finite ammo Resource (K/C) and a qualified Sprint (B/F/G/D).
- **MED** CON-CAND-005 — Persistence: module vs Kernel architecture (H & E say not-a-module; C, E, and H §10 elsewhere treat it as an owning module).
- **MED** CON-CAND-006 — Champion wounds: J says the card holds no runtime state; E adds a wound track to the Champion card.
- **MED** CON-CAND-007 — Morale: Resource vs State (unresolved from A, resurfaces in C).
- **STRUCT** CON-CAND-008 — "Standing": Position fact (I) vs Caravan resource (H).
- **STRUCT** CON-CAND-009 — Rally owner: "a leader" (B/H) vs "the Sergeant" (C).
- **LOW** CON-CAND-010 — Circle break: "never breaks" (B) vs "breaks by a prewritten trigger" (E/G).
