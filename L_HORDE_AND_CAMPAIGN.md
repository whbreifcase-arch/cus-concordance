# CUS — THE HORDE ENGINE & THE CAMPAIGN LOOP
### v0.6 · the campaign spine · signed 2026-07-28 (William)

> **What this is.** Two things the rest of CUS was waiting for: **(1)** the horde
> engine — nests, spawns, and recycling that turn "kill the enemy" into "survive the
> enemy," and **(2)** the campaign loop that wires the **Story** module (Doc I),
> the **scenario generator** ([SCENARIO_PROMPT](SCENARIO_PROMPT.md)), the **Combat**
> module (B + [K · Firearms](K_FIREARMS.md)), and **Persistence** (Doc H) into one
> repeating cycle with an AI as game-master.
>
> **It fills a reserved slot.** When `F_AI_DIRECTOR` was struck, its slot was
> **deliberately reserved** for William's own campaign-preparation system
> (E · `kill-ai-director`). This document is that system.
>
> **Authority.** L cites A (Kernel) and does not restate it. The horde engine is a
> **scenario/Procedure layer**, not a new module or primitive. Where L conflicts with
> A/B/K, they win. Story stays **PROPOSED** (Doc I) — L wires its *campaign use*, it
> does not sign it.

---

# 1 · The campaign loop — A·XII at campaign scale

The Kernel's universal decision loop (A·XII: Observe → Discern → Choose → Act →
Consequences → Persistence) is not just an in-battle loop. Run it at **campaign** scale
and it names the whole game:

```text
STORY session ─────────▶ acquire intel · alliances · leverage · resources
 (Doc I · AI as GM)          │  outputs become scenario INPUTS
                             ▼
SCENARIO generator ────▶ the mission: geometry · objective · initiative · forces
 (SCENARIO_PROMPT)           │
                             ▼
COMBAT mission ────────▶ the fight (B + K: the guns, the horde, the clash)
                             │
                             ▼
PERSISTENCE ───────────▶ wounds · scars · gear entropy · what it cost (Doc H)
                             │  feeds the next
                             └────────────▶ STORY session (the grudge earned, ally lost)
```

Two modules meeting at **the Figure** (A·XIX), Persistence carrying between, the AI
running the table. Nothing here is new architecture — it is the two-module design
**switched on as a play cycle.** `→ G·the-loop-is-the-kernel`

---

# 2 · The pre-mission Story session  `[Story · Doc I]`

**Before a shot is fired, players play a session as tacticians** — parley, gather
intel, lean on a faction, buy or bargain for support. This is **Story** (Doc I:
"contested everything else — the parley, the bargain, the grudge, the oath, the crowd")
in campaign use. Acquiring intel is an **Ask** resolved by Story; a political maneuver
is an Ask; an alliance is a **Vow** (a WAIT armed against a later trigger, A·XIV).

The session's **outcomes are structured, and they feed the generator** (§7). You are
not roleplaying for colour — you are **setting the mission's parameters** by what you
achieved before deployment. A squad that scouted the ground deploys knowing the lanes;
a squad that bribed a quartermaster fields an extra gun; a squad that learned nothing
walks in blind.

> Story is **PROPOSED, not signed** (Doc I). Its *campaign use* is wired here so the
> loop is playable now; its full resolution ruleset is still Doc I's to ratify.

---

# 3 · The horde engine  `[Position · Resource · State]` — SIGNED (William, 2026-07-28)

The signature PvE pressure: an enemy you **cannot out-kill**, only outlast or unmake.

```text
NEST      a board feature that SPAWNS horde models each round. It has its own health
          and its own Position. Kill the nest, stop the flow.
SPAWN     each round (or on a trigger) a nest emits N models at its mouth.
RECYCLE   a slain hordeling returns to the spawn POOL and re-enters from a nest.
          Killing a hordeling is TEMPORARY. The horde is a FAUCET, not a bucket.
```

The consequence reframes the whole game: because the bodies come back, **stacking kills
is time-buying, not progress.** The real target is the **nest** (or the clock). This is
the Kernel's own lesson — a numerical race (out-kill the spawns) is the wrong tool;
**Position** (reach and unmake the nest, or hold ground until the timer) is the right
one. `→ G·the-horde-is-a-faucet`

## The recycle dial — SIGNED
Two settings, one engine; the **scenario** picks:
```text
ENDLESS (infinite until the nest dies)  → defense / survival. The nest is the ONLY real
                                           target; "kill them all" is never a plan.
FINITE POOL (N bodies per nest)         → clear-out. Grind the flow down as an alternative
                                           to assaulting the nest. Killing has a point.
```

---

# 4 · The horde AI  `[Mission · Temperament]`

Hordes are run from canon, not puppeteered (Law 9). A horde runs on **Temperament =
Ravenous** (B·10 — "at whatever is nearest, indiscriminate, heedless of cost") under a
thin **Mission** (A·XI): *Intent = reach and consume; Focus = the nearest living thing;
Constraints = none.* That is the whole script. No SLOT budget, no boss director — the
deleted `F_AI_DIRECTOR` is not resurrected; the flood is emergent from Temperament +
spawn geometry. `→ G·a-flood-needs-no-director`

Elite enemies **within** a horde (a brood-lord, a nest-guardian) are **Circles** (B·10)
carrying their own break-triggers and Missions — the exception the horde is built around,
not a return of the director.

---

# 5 · Win, loss, and the clock  `[Resource: Time]`

```text
WIN   (a) SURVIVE / HOLD an area while the horde escalates to a timer, or
      (b) REACH and DESTROY the nests before you are overwhelmed.
LOSE  the squad is wiped, or the objective's clock runs out, or the nest count grows
      past what you can contain.
```

Both win paths are the same question — **can you last long enough?** — which is why the
mode is called *survival*.

## The limiter is not ammo — it is attrition
Reload is a card-down (K·6), not a bullet count, so **ammo does not end the mission.**
What ends it is **you**: your figures accumulate wounds and **scars** (Doc H), your gear
suffers **entropy** (it breaks, it fouls), and a scarred veteran becomes a liability
who must retire (E · `retirement`). The mission is a **race between the nest's pressure
and the squad's decay.** `→ G·attrition-is-the-clock`

---

# 6 · Intel & leverage → scenario modifiers

The Story session's outcomes (§2) are the generator's inputs. A working table the AI
scenario-designer reads:

```text
STORY OUTCOME                     → SCENARIO MODIFIER (SCENARIO_PROMPT input)
scouted the ground / recon        → the map's lanes/objectives revealed at deploy; +reserve
learned the enemy plan            → the horde/enemy Mission shown to the players in advance
bribed / requisitioned support    → +forces or +gear (a bigger points budget for one side)
political leverage / a favour      → a friendly objective, a starting position, or a turn of
                                     initiative
sabotage before the battle        → a nest starts damaged, or spawns a round later
learned nothing / burned a bridge  → deploy blind; the enemy holds an intel edge
```

The generator already balances by **scenario, not stat symmetry** (M · matchup
philosophy; SCENARIO_PROMPT). Intel and leverage are just more scenario dials — they
tilt the map, not the dice. `→ G·intel-tilts-the-map-not-the-dice`

---

# 7 · What this engine owes the Kernel

```text
It OWNS       the horde Procedures (nest · spawn · recycle · the survival win) and the
             campaign-loop wiring. It owns no primitive and no verb.
It READS/WRITES  Position (nests · spawn geometry · the objective), Resource (Time · the
             spawn pool), State (nest health · the objective clock).
It CITES     A·XI (Missions) · A·XII (the loop) · A·XIX (two modules at the Figure) ·
             B·10 (Temperament/Ravenous · Circles) · Doc H (Persistence/attrition) ·
             Doc I (Story, campaign use) · SCENARIO_PROMPT (the generator) ·
             E·kill-ai-director (the reserved slot this fills).
It MUST NOT  puppeteer a human's figures (Law 9), resurrect the SLOT/boss director, or
             let "out-kill the spawns" be a win condition.
```

The horde is a faucet; the campaign is a loop; the Story session sets the mission and
the mission scars the squad. It is the Kernel running at the scale a whole campaign
is played.
