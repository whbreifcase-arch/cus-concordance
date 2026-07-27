# CUS — Kernel Rebuild · v0.6
### Rebuilt from the KERNEL REBUILD BRIEF (2026-07-23)

This folder is the **new authority**. It rebuilds CUS from first principles per the
Rebuild Brief. Where anything here conflicts with an older CUS document
(`../CUS_CODEX.md`, `../CUS_COMBAT_NOTES.md`, the retired forks), **this folder
wins.** The old codex is now a **migration input, not authority.**

## The documents

| # | Document | Holds |
|---|---|---|
| **A** | [Kernel Constitution](A_KERNEL_CONSTITUTION.md) | Universal architecture only — the bones every module obeys. No weapon numbers, no armour saves, no base millimetres. |
| **B** | [Combat Module](B_COMBAT_MODULE.md) | The *reference implementation* — physical conflict, translated through the Kernel. Every mechanic cites the primitive it reads/writes. |
| **C** | [Kernel Dictionary](C_KERNEL_DICTIONARY.md) | One canonical definition per term. The Rosetta Stone. |
| **D** | [Migration Map](D_MIGRATION_MAP.md) | Every old term → its new owner or replacement. Nothing valuable is silently deleted. |
| **E** | [Decision Register](E_OPEN_DECISIONS.md) | The signed record of every ruling and amendment. **Not** a list of open questions — the filename is legacy, kept so links don't break. |
| **F** | [Continuous Clash Resolution](F_CLASH_RESOLUTION.md) | The governing spec for how a clash/"charge" resolves — increments, reaction order, the 3″ threshold. |
| **G** | [Why Not](G_WHY_NOT.md) | The rationale register. Every place CUS says "X is **not** Y," the argument lives here — so A–C can state rules instead of defending them. |
| **H** | [Persistence](H_PERSISTENCE.md) 🚧 | **HOLDING PEN — not a module.** Persistence is Kernel architecture and William is writing it into **A**. Until then the **harm and aftermath procedures** live here and are playable: the Aftermath rolls, 36 body injuries, 8 mind, 39 scars, and the 5-line battle result. |
| **I** | [Story](I_STORY.md) ⚠ | **PROPOSED — Combat's peer.** The parley, the bargain, the grudge, the oath, the crowd. Composure, the Retort, Bonds. Unsigned; the Register at its foot is the pen. |

## The two modules — A · XIX

```text
COMBAT   Document B ── contested force          BUILT     (clash spine closed, F)
STORY    Document I ── contested everything else PROPOSED  (drafted, unsigned)

PERSISTENCE — not a module. Kernel architecture, being written into A.
              Harm and Aftermath wait in H until it lands.
```

Two peers, meeting at **the Figure**. Neither is a species of the other, and
Combat is not the master (Law 12). **Play is analog; campaign bookkeeping needs
the companion app.**

> ⚠ **Nothing in I is authority yet.** Where it conflicts with A–H, A–H wins.

**Playable:** [tts/](tts/) — the Tabletop Simulator implementation. Two Lua
scripts; the miniature tracker pulls its units live from `factions/data/` over
HTTPS, so a balance change here is live in game on the next pick.

**Supporting:** [CHARGE_FINDINGS.md](CHARGE_FINDINGS.md) — what ~1.3M simulated
charges taught us (capstone, closed 2026-07-25) · [SCENARIO_PROMPT.md](SCENARIO_PROMPT.md)
— reusable prompt to make any AI a CUS scenario designer · `play/` — the live tools
(CHARGE_LAB, BANNER, BATTLE_3D, How To Play) · `factions/` — the v0.6-native faction
build and its sim.

## Owner rulings signed — 2026-07-24 (William)

All twelve open decisions are **signed** and folded into A/B/C:

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

## Amendments — 2026-07-25 (William)

Taken after an external consistency review of the published set:

```text
reaction-resource    → Reaction is a Kernel Resource, separate from AP (A·IV)
reaction-budget      → 1 per figure · 2 for a Circle, refreshed on activation (B·12)
counter-authoring    → a Counter is a Written Trigger inside a PACKET, not a WAIT
shield-cap           → no artificial cap: he spent his Reaction, and he can die
brace-vs-overwatch   → Brace grants no Reaction; Overwatch costs 1 AP AND 1 Reaction
sprint-to-charge     → the 3″ is the sprint→charge threshold, not a distance budget
wounds               → Wounds is a NUMBER (1–2 standard, a knob). Fine/Hurt deleted;
                       Knocked Out and Dead are the two real States
circle-scope         → one Circle per BANNER (its Champion); an Army holds one per
                       Banner, not one in total

── second batch ──
fists-standard       → every figure carries Fists. The Counter is universal; the only
                       gate is Reaction
reach-constraint     → Reach = `not_in_contact`: strikes to X", illegal while bases
                       touch. In contact you swing Fists
ranged-in-melee      → ranged carries `not_in_contact` BY DEFAULT; exceptions are
                       authored and priced
simultaneous-death   → both lethal? both die. No tiebreak
finish-the-downed    → a Knocked Out figure that is hit is killed, and rolls no Armour
morale-ratchet       → breaking beats killing; Rally is the only reliable valve
form-up              → SERGEANT-ONLY group MOVE: friendlies within 4", each pays 1 AP
                       and is ACTIVATED, all MOVE at once, strikes declared before
                       contact, you hit only what your base moves into. Reaction untouched
form-up-pace         → a formation moves at the SHORTEST Move among its members. A
                       body travels at the pace of its slowest man
move-stays-move      → the "Advance" alias is retired; MOVE is MOVE
invocation-layer     → 3 player verbs, 5 invocations (+ WRITTEN_TRIGGER, OWNED_PROCEDURE)
round-boundaries     → START OF ROUND defined; refresh stays on activation
kill-ai-director     → F_AI_DIRECTOR and its SLOT/Boss budget deleted, nothing salvaged
```

**CUS v0.6 is closed** — every decision is signed and **no open questions remain.**
See [Document E · Decision Register](E_OPEN_DECISIONS.md). The next change is an
amendment, not an open question.

## What changed at the root (closed rulings — Brief §17)

```text
MOVE · ATTACK · USE · READY   →   MOVE · ACTION · WAIT
Attack / Ability / Reactive packets → one neutral PACKET
Typed IDs (ATK_07)            →   neutral IDs (spear_thrust)
Ladder / Tiers / Rungs        →   Success Grade (Grade)
Charge (keyword)              →   Sprint (movement) + Impact (contact)
five Roles                    →   PRESSURE · ANCHOR · UTILITY
(new axis)                    →   TEMPO  ( > / >> / >>> )
(new Resource)                →   REACTION  (1 per figure · 2 per Circle)
Fine → Hurt → KO → Dead       →   Wounds is a NUMBER; KO and Dead are States
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
doing real work. **F** is how a clash actually resolves at the table.

Three reference documents answer three different "why" questions, and it's worth
knowing which one you want:

```text
"where did my old word go?"        → D · Migration Map
"who decided this, and when?"      → E · Decision Register
"why isn't it the obvious thing?"  → G · Why Not
```

## Convention used in these documents
- **`→ G·<slug>`** — the obvious reading of this rule is wrong, and
  [Document G](G_WHY_NOT.md) explains why. A–C state rules; they don't argue.
- **SIGNED** — a closed owner ruling. Stable. Cite it.
- **⚠ PROVISIONAL** — a SIGNED rule awaiting ratification **in play**. It is in
  force now; playing decides whether it stays. Not an open question.
- **⚠ OPEN → E·<topic>** — a genuine unanswered question. **There are currently
  none.**
