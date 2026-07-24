# CUS — Kernel Rebuild · v0.6
### Rebuilt from the KERNEL REBUILD BRIEF (2026-07-23)

This folder is the **new authority**. It rebuilds CUS from first principles per the
Rebuild Brief. Where anything here conflicts with an older CUS document
(`../CUS_CODEX.md`, `../CUS_COMBAT_NOTES.md`, the retired forks), **this folder
wins.** The old codex is now a **migration input, not authority.**

## The five documents

| # | Document | Holds |
|---|---|---|
| **A** | [Kernel Constitution](A_KERNEL_CONSTITUTION.md) | Universal architecture only — the bones every module obeys. No weapon numbers, no armour saves, no base millimetres. |
| **B** | [Combat Module](B_COMBAT_MODULE.md) | The *reference implementation* — physical conflict, translated through the Kernel. Every mechanic cites the primitive it reads/writes. |
| **C** | [Kernel Dictionary](C_KERNEL_DICTIONARY.md) | One canonical definition per term. The Rosetta Stone. |
| **D** | [Migration Map](D_MIGRATION_MAP.md) | Every old term → its new owner or replacement. Nothing valuable is silently deleted. |
| **E** | [Open Decisions](E_OPEN_DECISIONS.md) | Genuine unresolved calls, isolated and **unanswered** — each awaits an owner ruling. |

## Owner rulings signed — 2026-07-24 (William)

Seven of the eight open decisions are now **signed** and folded into A/B/C:

```text
grade-accumulation   → Model 2 (discrete: Grade N resolves only its own Effects)
persistent-traits    → Traits = referenced passive Definitions (keyword: trait)
tool-vocabulary      → combat Tool set = Melee · Ranged · Hybrid (vibe-check)
temperament          → 5 words + leaderless/Rout behaviour table (delegated → designed)
force-ontology       → Force IS a formal Kernel primitive (non-numerical)
packet-classification→ neutral ID + packet_index sidecar (delegated → designed)
base-classes         → Small · Medium · Large (no Monstrous, no Cavalry-as-class)
engagement           → bases touching = engaged · Reach 1–2″ · Disengage 1 AP
counter              → turn-and-face · no cap · dying swing lands · Circles faceless
morale-states        → Steady → Shaken → Broken (Broken = Rout by Temperament)
nerve-trigger        → shock (wounded / ally falls within 3″) → roll 3, count Nerve
counter-loop         → a Counter does not itself draw a Counter
```

**CUS v0.6 is closed** — every decision is signed. See [Document E](E_OPEN_DECISIONS.md).
The next change is an amendment, not an open question.

## What changed at the root (closed rulings — Brief §17)

```text
MOVE · ATTACK · USE · READY   →   MOVE · ACTION · WAIT
Attack / Ability / Reactive packets → one neutral PACKET
Typed IDs (ATK_07)            →   neutral IDs (spear_thrust)
Ladder / Tiers / Rungs        →   Success Grade (Grade)
Charge (keyword)              →   Sprint (movement) + Impact (contact)
five Roles                    →   PRESSURE · ANCHOR · UTILITY
(new axis)                    →   TEMPO  ( > / >> / >>> )
```

## What was preserved (earned its place — Brief §20)

```text
one owner · one module · recursive scale · definitions hold no state
intent separate from resolution · the table is the interface
descriptive geometry · player agency · AI Missions are constrained intent
Position creates tactical depth · Force creates functional identity
```

## Reading order
Start with **A**. Read **C** alongside it as a glossary. **B** shows the Kernel
doing real work. **D** tells you where your old vocabulary went. **E** is the
list of things the Kernel deliberately does **not** yet decide — do not treat a
blank in E as an omission; it is a question waiting for you.

## Convention used in these documents
- **SIGNED** — a closed ruling from Brief §17; stable.
- **⚠ OPEN → E·<topic>** — a genuine gap. The text presents the coherent options
  and defers to [Document E](E_OPEN_DECISIONS.md). It is never silently resolved.
