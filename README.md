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
| **F** | [Continuous Clash Resolution](F_CLASH_RESOLUTION.md) | The governing spec for how a clash/"charge" resolves — increments, response order, the 3″ threshold. |
| **G** | [Why Not](G_WHY_NOT.md) | The rationale register. Every place CUS says "X is **not** Y," the argument lives here — so A–C can state rules instead of defending them. |
| **H** | [Persistence](H_PERSISTENCE.md) 🚧 | **HOLDING PEN — not a module.** Persistence is Kernel architecture and William is writing it into **A**. Until then the **harm and aftermath procedures** live here and are playable: the Aftermath rolls, 36 body injuries, 8 mind, 39 scars, and the 5-line battle result. |
| **I** | [Story](I_STORY.md) ⚠ | **PROPOSED — Combat's peer.** The parley, the bargain, the grudge, the oath, the crowd. Composure, the Retort, Bonds. Unsigned; the Register at its foot is the pen. |
| **J** | [The Component Layer](J_COMPONENTS.md) | **The analog interface.** How state, capability and campaign live on a real table — the Component Law, one-card-per-unit + hand management, the on-model state table, base construction. Presentation (A·IX), not a module; discharges A·XIX's "play is analog." |
| **K** | [Firearms & Ranged Warfare](K_FIREARMS.md) | **The universal firearm engine.** Combat Module extension — gun = Ranged PACKET; the grade ladder (Suppress/Pin → Wound → Cripple); Spray, Blast + Scatter, Ammo/Reload + Misfire, Heat, Overcharge, Evasion. Setting-agnostic: a flintlock and an autogun run the same math. |
| **L** | [Horde & Campaign](L_HORDE_AND_CAMPAIGN.md) | **The horde engine + the campaign loop.** Nests, spawns, recycle (survive/destroy, not out-kill) — fills the reserved AI-director slot — plus the pre-mission Story session feeding the scenario generator (A·XII at campaign scale). |
| **M** | [The Sci-fi Setting](M_SCIFI_SETTING.md) | **A content pack, not the Kernel.** Four factions (Marines · Guard · Tau · Orks), the asymmetric-+-mirror matchup philosophy, the sub-faction/Chapter flavor layer. Invents no rule; a separate setting sharing the K engine. |

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

**Playable:** [tts/](tts/) — the Tabletop Simulator build. **`tts/kit/`** is the
live one: a per-miniature tracker plus a Global that stamps units onto minis from
an 81-unit library generated out of `factions/data/`. No cards, no linking, and
no XML slot at all. `tts/mod/` is the older full mod, kept for its build
pipeline.

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
reaction-resource    → STRUCK 2026-07-27. See the third batch below
reaction-budget      → STRUCK 2026-07-27. See the third batch below
counter-authoring    → a Counter is a Written Trigger inside a PACKET, not a WAIT
shield-cap           → no artificial cap: the cap is that he can die eating it
brace-vs-overwatch   → the two WAITs. Brace buys a better front, Overwatch a better
                       armed packet. Neither buys permission — they're free to fire
sprint-to-charge     → the 3″ is the sprint→charge threshold, not a distance budget
wounds               → Wounds is a NUMBER (1–2 standard, a knob). Fine/Hurt deleted;
                       Knocked Out and Dead are the two real States
circle-scope         → one Circle per BANNER (its Champion); an Army holds one per
                       Banner, not one in total

── second batch ──
fists-standard       → every figure carries Fists. The Counter is universal; what
                       gates it is Position
reach-constraint     → Reach = `not_in_contact`: strikes to X", illegal while bases
                       touch. In contact you swing Fists
ranged-in-melee      → ranged carries `not_in_contact` BY DEFAULT; exceptions are
                       authored and priced
simultaneous-death   → both lethal? both die. No tiebreak
finish-the-downed    → a Knocked Out figure that is hit is killed, and rolls no Armour
morale-ratchet       → breaking beats killing; Rally is the only reliable valve
form-up              → SERGEANT-ONLY group MOVE: friendlies within 4", each pays 1 AP
                       and is ACTIVATED, all MOVE at once, strikes declared before
                       contact, you hit only what your base moves into. Triggers untouched
form-up-pace         → a formation moves at the SHORTEST Move among its members. A
                       body travels at the pace of its slowest man
move-stays-move      → the "Advance" alias is retired; MOVE is MOVE
invocation-layer     → 3 player verbs, 5 invocations (+ WRITTEN_TRIGGER, OWNED_PROCEDURE)
round-boundaries     → START OF ROUND defined; refresh stays on activation
kill-ai-director     → F_AI_DIRECTOR and its SLOT/Boss budget deleted, nothing salvaged

── third batch · 2026-07-27 · THE REACTION ECONOMY IS STRUCK ──
reaction-struck      → Reaction is no longer a Resource. No pool, no budget, no
                       per-trigger cost. Out-of-turn response is gated by POSITION,
                       AUTHORING and DEATH — never by a number
counter-is-free      → a Counter costs nothing. Contact · facing · provokes · death
provokes             → the STRIKING packet decides whether it draws a Counter. True by
                       default for melee in contact; a backstab authors it false
trigger-once-per-    → a Written Trigger fires once per occurrence, and a movement is
  occurrence           one occurrence however finely a clash slices it
wait-buys-quality    → WAIT is the only AP-priced out-of-turn capability and it buys
                       QUALITY, not permission. "Arming is not permission" is struck
facing-is-the-cap    → what replaced the pool is the front arc: a Square answers what
                       it faces, a faceless Circle answers everyone
```

## Amendments — 2026-07-27 · fourth batch (William)

One working session: the Overwatch shot, Position as the primary currency, the
campaign economy, and the **physical component layer** — the last opening a new
Presentation document, **[J · The Component Layer](J_COMPONENTS.md)**:

```text
overwatch-exhaustible→ an armed Overwatch fires ONCE and is spent. Asymmetry with the
                       free repeatable Counter: a ranged cone has no flank, so a free
                       lane would be absolute and screens pointless
shot-ladder          → prior movement prices the shot. Sprinted to the lane → Quick
                       only; held ground you owned → Precise. The tempo layer the
                       struck Reaction refresh gave, rebuilt positionally
position-is-currency → ground has value, so waiting costs ground. Lanes + threat
                       projection are the core game; screens answer lanes
no-lane-exempt-      → an assassin must TANK the lane, not skip it. No teleport/reserve/
  archetype            outsized-move that exempts one archetype from the game
entropy-is-the-      → gear breaks, boosts are temporary, lifestyle creep bites. Entropy
  leveler              is the leveler and it dissolves the mandatory checklist
progression-at-      → individuals decline; institutions ascend. Compatible with
  institution          progression-location — the Figure's Instance still owns its own
                       mechanics; the institution is just another entity that accrues
component-law        → six principles: state on the model · capability on the card ·
                       campaign in the app · subtractive>additive · encode the
                       exception · the base is the measuring instrument
cards                → one printed card per unit (front player-facing, back packets);
                       holding them IS hand management; a facedown at a model = the
                       WAIT trap, no draw variance
on-model-state       → activation flag · nerve flag (Steady gets none) · health by
                       orientation · armour WYSIWYG · AP in your head
base-construction    → two poka-yoke magnet wells (2mm/1.5mm) booleaned into every
                       base as terrain; the base may never extend the contact perimeter
multi-area-maps      → a REQUIREMENT, not a preference — written into the scenario
                       generator's hard constraints, because one decisive point re-
                       freezes the board

── playtest watch-list (⚠ PROVISIONAL / tuning, NOT reopened questions) ──
free-facedown · shove-load-bearing · form-up-stress · upkeep-curve
(superlinear vs proportional) · champion-wounds · lost-tempo-read
```

## Amendments — 2026-07-28 · fifth batch (William)

Firearms, the horde-survival mode, four sci-fi factions, and the campaign loop —
three new documents (**[K · Firearms](K_FIREARMS.md)**, **[L · Horde &
Campaign](L_HORDE_AND_CAMPAIGN.md)**, **[M · Sci-fi Setting](M_SCIFI_SETTING.md)**):

```text
firearms-are-packets → a gun is a Ranged PACKET; no shooting phase, no new verb.
                       not_in_contact + provokes:false are automatic. The engine is
                       SETTING-AGNOSTIC — a flintlock and an autogun run the same math
gun-grade-ladder     → a shot climbs Suppress/Pin → Wound → Cripple/Kill; you may shoot
                       to pin, not just to wound. Dice decide how high you climb
spray                → the ranged twin of Cleave — walk the blob, -1 die per hop
blast + scatter      → the one new effect type: an INDIRECT (no LoS) band template that
                       scatters (shot-ladder-gated); friendly fire on
ammo / misfire / heat→ three limiters. Ammo (magazine, reload=card-down) · Misfire
                       (blackpowder) · Heat (energy, "gets hot"). Reloading the whole
                       squad at once is the designed terror
overcharge           → spend the limiter for +1 die or ignore-Armour this shot
evasion              → a DODGE save that beats ignore-Armour/blast — corner them, don't
                       out-gun them (Tau)
setting-split        → one engine, content per era. FANTASY = blackpowder; SCI-FI (M) =
                       autoguns/plasma. Never mix eras in one warband
horde-engine         → the horde is a FAUCET (nests spawn, dead recycle); win = survive
                       or kill the nest. Fills the reserved AI-director slot
campaign-loop        → the pre-mission STORY session (Doc I, campaign use) sets the
                       mission via the scenario generator. A·XII at campaign scale
four-factions        → Marines (no-fear elite) · Guard (artillery+Orders) · Tau (Evasion
                       kite) · Orks (Mob+berserker, 3 wounds/no shrug)
matchups-asymmetric  → PvP is asymmetric, balanced by SCENARIO not stat symmetry; the
                       50/50 mode is a MIRROR (same faction, different Chapter)
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
Fine → Hurt → KO → Dead       →   Wounds is a NUMBER; KO and Dead are States
REACTION (added 2026-07-25)   →   STRUCK 2026-07-27. Answering is free; POSITION caps it
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
