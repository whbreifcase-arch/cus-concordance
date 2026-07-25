# CUS — FIRST BATTLE · SCREEN MAP & BRANCHING FLOW
### Part One: Your First Activation · spec v1.0 · 2026-07-25

> **What this is.** The complete screen-by-screen specification for the **LEARN TO PLAY**
> door of *Play CUS* — exact on-screen text, diagram brief, button behaviour and branch
> target for every screen.
>
> **What this is not.** It is not a rules document. Every rule statement below is
> *rendered from* `play/rules.js`, which is rendered in turn from the signed v0.6 kernel
> (`A_KERNEL_CONSTITUTION.md`, `B_COMBAT_MODULE.md`). If a rule here disagrees with B,
> **B wins and `rules.js` is wrong.** No rule text is hand-authored on a screen.
>
> **Authority.** CUS v0.6, CLOSED 2026-07-24. Provisional content (shields · brace ·
> shove, `B·9b`) is flagged and is **excluded from Part One entirely.**

---

# 0 · How to read this document

## 0.1 The screen record

Every screen is specified as one record:

| Field | Meaning |
|---|---|
| **Renders from** | the `rules.js` rule id(s) supplying every word of rule text |
| **Fires when** | the machine condition that brings the player here |
| **New terms** | count of formal terms introduced (hard limit: **1**, exceptions listed in §8) |
| **Words** | instructional word count (hard limit: **35**) |
| **On screen** | the exact text, verbatim, in render order |
| **Diagram** | asset id + brief, written in the §0.2 token language |
| **Buttons** | label · enabled-state · branch target |

## 0.2 The diagram token language

Locked from the existing poster footer — this is **not new**, it is the grammar already
shipping in `CUS_HOW_TO_PLAY_v1_5.html`. Every diagram in this spec is written in it.

```text
BLACK solid base    the figure currently acting
WHITE outlined base the figure receiving
GREY base           present but irrelevant this screen
DASHED base         where a figure WAS
SOLID base          where a figure IS
NOTCH on base edge  facing (Squares only — Circles have none)
HATCHING            wall / impassable
GOLD                movement · action · bonus · legal choice
RED                 wound · death · failed check · illegal destination
THIN RING           reach or effect distance
BIG ARROW           forced movement
SMALL CURVED ARROW  reface / rotate
```

**Rule:** a diagram may not introduce a mark that is not in this table. If a concept
needs a new mark, the mark is added *here first* and applied to every existing diagram.

## 0.3 Screen anatomy — enforced on every screen

```text
┌──────────────────────────────────────────┐
│ ‹ back      LESSON TITLE          ✕ exit │   top strip
├──────────────────────────────────────────┤
│                                          │
│            DIAGRAM / BOARD               │   58% of viewport height
│                                          │
├──────────────────────────────────────────┤
│ TRIGGER — what just happened             │
│ **RULE NAME** — the formal term          │   instruction block
│ Instruction — what to do now             │
│ Consequence — what changed               │
├──────────────────────────────────────────┤
│  [ ONE DOMINANT BUTTON ]                 │
│  see exact rule · replay                 │   bottom controls
└──────────────────────────────────────────┘
```

No sidebar. No footer. No menu. No neighbouring lesson. No vertical scroll.

**Progress indicator — deviation from brief §5.** The brief asks for `3 / 7` in the top
strip. The spine **branches**, so a global fraction would lie (a player who Sprints sees
a different number of screens than one who Attacks). Therefore:

- **Spine screens** show the real progress — **AP pips** (`● ○`) plus the activation
  phase. That *is* the progress bar; the activation ends when the pips are out.
- **Encounter lessons** show `n / N` within the lesson only, because a lesson is linear.

---

# 1 · The scripted board

Part One is a **real board with real state** — live AP, real positions, real dice. The
"what happened?" questions in the original brief are therefore **not menus**; the game
already knows. See §2.2.

## 1.1 The figures — mirrored verbatim from `CUS_FACTIONS/data/`

**Player figure — `MIL_SWORD` · Militia Swordsman**

| | |
|---|---|
| Base | **Square** · Medium · not mounted |
| AP | **2** |
| Wounds | 2 · Armour **Medium (5+)** · Nerve **3** · Speed **6″** |
| Axes | Pressure · `>>` · Melee · Resolute · Man · Swordsman · Rank I |
| Traits | **none** |
| Packet | `militia_sword` — 3 dice · **4+** · melee · 1 AP |

> **Why this figure.** It carries **zero traits**. Every other militia body drags an
> exception onto the first screen a beginner sees — the Sergeant has `reach`, the
> Watchman has `shield` (provisional!), the Spearman has a reach weapon, the Levy is
> Small. The Swordsman is the only militia profile with no exception attached, which is
> exactly principle §6 of the brief: *no exception unless it is currently happening.*

**Enemy figures — `GOB_WARRIOR` · Goblin Warrior ×3**

| | |
|---|---|
| Base | **Square** · Small · not mounted |
| AP | 2 |
| Wounds | **1** · Armour **Light (6+)** · Nerve **4** · Speed 7″ |
| Axes | Pressure · `>>` · Melee · **Cowardly** · Man · Warrior · Rank I |
| Traits | `expendable` |
| Packet | `goblin_shiv` — 2 dice · 4+ · melee · 1 AP |

> **Why goblins.** The `expendable` trait is defined in `traits.json` as: *"Its fall
> within 3″ is a shock that tests nearby allies' Nerve."* The Nerve lesson is therefore
> **caused by the board**, not staged. One goblin dies, the goblin beside it tests, it is
> Cowardly with Nerve 4 and it runs. The whole consequence chain fires from one attack.

## 1.2 Layout — 12″ × 12″, player south, enemy north

```text
   x→  0    2    4    6    8    10   12
 y=11  ·    ·    ·    ·    ·    ·    ·
 y=10  ·    ·    ·   ⬤OBJ  ·    ·    ·     ← objective, GOLD, pulsing
 y= 9  ·    ·  ▨▨▨▨▨▨▨▨▨▨▨▨▨  ·         ← ruined wall, HATCHED, gap at x=4
 y= 8  ·    ·    ·    ·    ·    ·    ·
 y= 7  ·    ·    ·    ·    ·    ·    ·
 y= 6  ·    ·   [C]  [A]  [B]  ·    ·     ← goblin line, notches face SOUTH
 y= 5  ·    ·    ·    ·    ·    ·    ·
 y= 4  ·    ·    ·    ·    ·    ·    ·
 y= 3  ·    ·    ·    ·    ·    ·    ·
 y= 2  ·    ·    ·   [S]   ·    ·    ·     ← Swordsman, notch faces NORTH
```

| Marker | Figure | Position | Why it is there |
|---|---|---|---|
| `[S]` | Militia Swordsman | (6.0, 2.0) | the player |
| `[A]` | Goblin Warrior A | (6.0, 6.0) | **4.0″** ahead — one MOVE reaches contact with 2″ to spare |
| `[B]` | Goblin Warrior B | (7.6, 6.0) | **1.6″** from A — inside the 3″ shock band → the Nerve trigger |
| `[C]` | Goblin Warrior C | (4.4, 6.0) | **1.6″** from A — the body that blocks the sideways shove |
| `▨` | ruined wall | y = 9.0, x = 2→10, **gap at x = 4.0** | the Crush surface, and the objective route |
| `⬤` | objective | (6.0, 10.0) | 8″ away, **behind the goblins** — you cannot walk around the lesson |

**Every distance is load-bearing:**

- **4.0″ to contact** vs **Speed 6″** — one MOVE reaches the enemy *and* leaves slack, so
  the player learns MOVE is a distance they choose, not a jump to the enemy.
- **1.6″ A↔B** — inside 3″. When A dies, B suffers a shock. The Nerve lesson is *earned*.
- **1.6″ A↔C** — C blocks A's westward shove, so a Sprint resolves to **Indent**, not
  Push. See §5.7 and the open question in §9.3.
- **Gap at x = 4.0** — the wall is not solid, so the objective stays reachable and the
  scenario is winnable. This matters: the tutorial must not teach a board you cannot win.

## 1.3 What the tutorial deliberately does **not** put on this board

| Excluded | Because |
|---|---|
| Circles | one activation cannot teach both base types; Circle is a *comparison chip* on FB-03 only |
| Reach | the Swordsman has none — Reach appears in HELP and FULL REFERENCE |
| Ranged | the Swordsman has none — no ranged packet is reachable in Part One |
| Shield / Brace / Shove | **provisional** (`B·9b`) — nothing unratified is taught to a beginner |
| Mounted · Large · Unstoppable | no such figure is on the board |
| Mob | needs three attackers on one target; not reachable in one activation |
| End of round | the brief is right — do not explain it yet |

---

# 2 · The state model

## 2.1 What First Battle tracks

```js
state = {
  ap_left:        2,        // decrements on MOVE / ACTION / WAIT
  attack_used:    false,    // gates ACTION — one attack per activation
  activation_over:false,    // set by WAIT, or by ap_left === 0
  engaged_with:   null,     // figure id or null
  moves_this_activation: 0, // 2nd MOVE === Sprint
  facing:         'N',
  wounds:         { S:0, A:0, B:0, C:0 },
  morale:         { A:'Steady', B:'Steady', C:'Steady' },
  seen_lessons:   Set(),    // a lesson never fires twice
}
```

## 2.2 The single biggest change from the brief

The original brief specifies **Screen M2 "What happened?"** and **Screen A3 "What
happened?"** as menus the player picks from:

> *"I moved into an enemy · I moved a second time · Nothing special happened"*

With a real board, **the game already knows**, and asking is worse than not asking — it
teaches the player to self-diagnose a rule they have not been taught yet, which is
precisely the failure mode this whole redesign exists to fix.

**Therefore M2 and A3 are not screens. They are routers.** Zero pixels. The engine reads
state and jumps straight to the lesson the board just caused. Two screens deleted, and
the tutorial gets *more* honest, not less.

```js
// ROUTER-M — after any MOVE resolves
if (moves_this_activation === 2)   → LE-SPRINT → LE-IMPACT
else if (engaged_with !== null)    → LE-ENGAGED
else                               → FB-04 (hub)

// ROUTER-A — after an ACTION fully resolves (B·5 order)
if (target.wounds >= target.max)   → LE-WOUND(kill) → LE-COUNTER → ROUTER-N
else if (wounds_landed > 0)        → LE-WOUND(hurt) → LE-COUNTER → ROUTER-N
else                               → LE-COUNTER → FB-04

// ROUTER-N — shock check, B·10
if (any friendly Square Man/Beast within 3" of a slain/Broken friend)
                                   → LE-NERVE → (if Broken) LE-TEMPERAMENT
else                               → FB-04
```

## 2.3 The AP loop — the structural hole in the original brief

The brief's Screen 4 is a **line**. It is a **loop**. A figure with AP left returns to the
hub after every branch. Three things close the loop, and the brief names none of them:

| Gate | Rule | Where it is taught |
|---|---|---|
| `ap_left === 0` | 1 AP = one MOVE, ACTION or WAIT | FB-04 pips, drained |
| `activation_over` | **WAIT ends the activation** | FB-W1 body text |
| `attack_used` | **One attack per activation** | FB-04 greyed ACTION tile |

### The greyed ACTION tile — full spec

Fires when `ap_left > 0 && attack_used === true`.

```text
  ┌──────────┐ ┌──────────┐ ┌──────────┐
  │  MOVE    │ │ ░ACTION░ │ │  WAIT    │
  │  1 AP    │ │ ░ used ░ │ │  1 AP    │
  └──────────┘ └░░░░░░░░░░┘ └──────────┘
       ONE ATTACK PER ACTIVATION
       AP  ● ○
```

- ACTION tile at 35% opacity, `aria-disabled="true"`, not focusable.
- Caption `ONE ATTACK PER ACTIVATION` appears **only** in this state — never before it
  bites. This is the brief's own event-trigger principle applied to a *constraint*.
- Tapping the dead tile does not navigate; it pulses the caption once.

> ⚠ **Honest note on reachability.** With the 2-AP Swordsman this state is **not reachable
> in Part One** — MOVE + ACTION drains the pips, so the loop exits before the gate can
> bite. It is fully specified here because (a) HELP mode and FULL REFERENCE both need it,
> and (b) it fires the moment the player uses a 3-AP figure in ordinary play — the Watch
> Captain, or the Watch Sergeant. **Part Two ("Your Second Figure") is where it teaches.**
> The alternative — giving the tutorial a 3-AP figure — costs more than it buys: the only
> 3-AP Square in the militia is the Sergeant, and it carries `reach`.

---

# 3 · The spine — 9 screens

```text
FB-01 objective
   ↓
FB-02 alternation
   ↓
FB-03 read the figure
   ↓
FB-04 ┌── HUB ─────────────────────────┐ ←──────────────┐
      │  MOVE      ACTION      WAIT    │                │
      └───┬──────────┬──────────┬──────┘                │
          ↓          ↓          ↓                       │
       FB-M1      FB-A1      FB-W1                      │
          ↓       FB-A1b        ↓                       │
     [ROUTER-M]   FB-A2    (activation_over)            │
          ↓       FB-A2b        ↓                       │
    lessons…      FB-A2c        ↓                       │
          ↓          ↓          ↓                       │
          │     [ROUTER-A]      │                       │
          │          ↓          │                       │
          │      lessons…       │                       │
          │          ↓          │                       │
          └──────────┴──────────┴─→ ap_left > 0 ? ──────┘
                                       ↓ no
                                    FB-99 pass play
```

---

## FB-01 · The Objective

| | |
|---|---|
| **Renders from** | `OBJECTIVE` |
| **Fires when** | tutorial start |
| **New terms** | 1 — *Objective* |
| **Words** | 14 |

**On screen**

> ### COMPLETE THE OBJECTIVE
>
> Every scenario tells you what must be won.
> Everything else is how you win it.

**Diagram** — `obj-establish`
Full board, top-down, §1.2 layout. The objective at (6,10) is **GOLD** and pulses slowly.
Every figure — both sides — is **GREY**. The wall is **HATCHED**. No arrows, no labels, no
distances. The player's first image of CUS is *the thing you are trying to reach*, not a
fight. One pulse cycle: 1.4s, ease-in-out, opacity 0.55 → 1.0.

**Buttons**

| Label | State | → |
|---|---|---|
| **BEGIN BATTLE** | enabled | FB-02 |

---

## FB-02 · Alternating Play

| | |
|---|---|
| **Renders from** | `ALTERNATION` |
| **Fires when** | from FB-01 |
| **New terms** | 1 — *activate* |
| **Words** | 16 |

**On screen**

> ### ACTIVATE ONE FIGURE
>
> Choose one figure that has not activated.
> When it finishes, your opponent chooses one.

**Diagram** — `alt-focus`
Same board, same camera — **do not move the camera between FB-01 and FB-02.** The
Swordsman becomes **BLACK solid**; every other figure and the objective drop to **GREY** at
30% opacity. A soft gold ring sits under the Swordsman. Beneath the board, a two-tile
strip: `YOU` (gold, filled) → `OPPONENT` (grey, hollow), with a small right-arrow between.

**Deliberately absent:** end of round. Round structure is not taught in Part One.

**Buttons**

| Label | State | → |
|---|---|---|
| **CHOOSE THIS FIGURE** | enabled | FB-03 |

---

## FB-03 · Read the Figure

| | |
|---|---|
| **Renders from** | `AP`, `BASE_SQUARE` (+ `BASE_CIRCLE` as comparison only) |
| **Fires when** | from FB-02 |
| **New terms** | 1 — *AP* |
| **Words** | 21 |

**On screen**

> ### THIS FIGURE HAS 2 AP
>
> AP is what a figure can spend this activation.
> Read it off the base.
>
> `● ●`
>
> ▸ **SQUARE — 2 AP** · this figure
> ▸ *Circle — 3 AP*

> **Deviation from brief §3, Screen 3.** The brief prints *"THIS FIGURE HAS 3 AP · Circle
> bases have 3 AP, Square bases have 2 AP."* That rule is **false in the shipped data** —
> `MIL_SERGEANT` is a Square with `max_ap: 3`. A tutorial must not teach a law its own
> warband breaks. The screen therefore teaches **"read it off the base"**, with Circle 3 /
> Square 2 demoted from *law* to *printed default*. The headline number is read from
> `figure.stats.max_ap`, never hard-coded.

**Diagram** — `ap-read`
The Swordsman base, **BLACK solid**, at ~2.5× board scale, viewed top-down, **NOTCH**
visible at the north edge. Two large gold AP pips sit above it, both filled. Below and at
half size, a **GREY** Circle base with three hollow pips — labelled, never explained.
No facing lesson, no flank lesson, no Nerve, no traits. One number.

**Buttons**

| Label | State | → |
|---|---|---|
| **SPEND AP** | enabled | FB-04 |

---

## FB-04 · The Three Verbs · **HUB · LOOP POINT**

| | |
|---|---|
| **Renders from** | `VERBS`, `MOVE`, `ACTION`, `WAIT` |
| **Fires when** | from FB-03, **or** returning from any branch with `ap_left > 0 && !activation_over` |
| **New terms** | **3** — the one sanctioned exception (§8) |
| **Words** | 12 |

**On screen**

> ### SPEND 1 AP
>
> | | | |
> |---|---|---|
> | **MOVE** | **ACTION** | **WAIT** |
> | Change position now. | Resolve a packet now. | Arm a packet for later. |
>
> `AP ● ●`

**Diagram** — `verbs-hub`
Three large tiles, each 1:1 aspect, filling the visual area. Icons, in the token language:

- **MOVE** — dashed base → gold path → solid base
- **ACTION** — black base, gold burst on a white base
- **WAIT** — black base with a small gold packet card tucked behind it, and a clock arc

The board shrinks to a 20%-height strip above the tiles so the player never loses the
board. AP pips sit under the tiles, filled = remaining.

**Buttons** — the tiles *are* the buttons. There is no Continue.

| Tile | State | → |
|---|---|---|
| **MOVE** | enabled while `ap_left > 0` | FB-M1 |
| **ACTION** | enabled while `ap_left > 0 && !attack_used` · else **greyed**, see §2.3 | FB-A1 |
| **WAIT** | enabled while `ap_left > 0` | FB-W1 |

**Loop exit:** when `ap_left === 0` or `activation_over === true`, the hub is skipped and
control passes to **FB-99**.

---

## FB-99 · Pass Play

| | |
|---|---|
| **Renders from** | `ACTIVATED`, `ALTERNATION` |
| **Fires when** | `ap_left === 0 \|\| activation_over` |
| **New terms** | 1 — *Activated* |
| **Words** | 15 |

**On screen**

> ### YOUR ACTIVATION IS OVER
>
> Mark the figure **Activated**.
> Your opponent now chooses one figure.

**Diagram** — `pass-play`, three-frame, 1.8s total
1. AP pips drain to hollow (`● ●` → `○ ○`), 0.4s
2. A gold **ACTIVATED** band sweeps across the Swordsman's base, which desaturates to GREY, 0.6s
3. The nearest goblin lifts to **BLACK solid** with a gold ring, 0.8s

The `YOU → OPPONENT` strip from FB-02 flips: `YOU` hollows, `OPPONENT` fills.

**Buttons**

| Label | State | → |
|---|---|---|
| **PASS TO OPPONENT** | enabled | end of Part One → summary card |
| *see exact rule* | always | `ALTERNATION` in FULL REFERENCE |

**End card** (not a lesson screen — a closing frame):

> ### THAT IS ENOUGH TO PLAY
>
> Everything else arrives when it happens on the board.
>
> `[ PLAY ON ]` → HELP ME NOW · `[ SEE THE FULL RULES ]` → FULL REFERENCE

---

# 4 · The three branches

## 4.1 MOVE branch

### FB-M1 · Move

| | |
|---|---|
| **Renders from** | `MOVE` |
| **New terms** | 0 (MOVE named on FB-04) |
| **Words** | 15 |

**On screen**

> ### MOVE — 1 AP
>
> Move up to **6 inches** — this figure's Speed.
> Drag the path, then release.

**Diagram** — `move-drag` · **interactive**
Board at full size. The Swordsman is **BLACK solid** at its start. As the player drags:

- a **DASHED** base is left at the origin
- a **GOLD** path follows the finger
- a live distance label rides the path head: `2.4″`
- a **GOLD** ghost base previews the destination
- beyond 6″ the path turns **RED** and the ghost is refused

Two labelled ticks on the path ruler — the only guidance given:

```text
    ├──────────────┼────────┤
    0            4.0″      6.0″
                CONTACT    MAX
```

Releasing snaps within 0.25″ of a tick. **The player chooses the distance** — this is the
screen where CUS stops being a boardgame of squares.

**Buttons**

| Label | State | → |
|---|---|---|
| **FINISH MOVE** | enabled once a legal path exists | resolve, `ap_left--`, `moves_this_activation++`, → **ROUTER-M** |

### ROUTER-M · no screen

| State after the move | → |
|---|---|
| `moves_this_activation === 2` | **LE-SPRINT** → **LE-IMPACT** |
| `engaged_with !== null` | **LE-ENGAGED** |
| otherwise | **FB-04** |

---

## 4.2 ACTION branch

### FB-A1 · Choose a Packet

| | |
|---|---|
| **Renders from** | `ACTION`, `PACKET`, packet `militia_sword` |
| **New terms** | 1 — *packet* |
| **Words** | 13 |

**On screen**

> ### ACTION — 1 AP
>
> Choose one of this figure's packets.
> A packet is a thing it can do.

**Diagram** — `packet-choose`
**The real card, not a rules paragraph.** Rendered from `packets_family.json`:

```text
  ┌────────────────────────────────┐
  │  COMMON WEAPON                 │
  │  3 DICE  ·  4+  ·  MELEE  ·  1 AP │
  ├────────────────────────────────┤
  │  GRADE 1   1 Wound             │
  │  GRADE 2   1 Wound · Shove     │
  │  GRADE 3   2 Wounds            │
  └────────────────────────────────┘
```

It is the figure's **only** packet, so it is pre-selected and gold-ringed. The player sees
a list of one — which quietly teaches that packets are a *list*, without a word spent.
Grade lines are visible but **dimmed**; nothing about Grades is explained yet.

**Buttons**

| Label | State | → |
|---|---|---|
| **CHOOSE TARGET** | enabled | FB-A1b |

### FB-A1b · Declare the Target

| | |
|---|---|
| **Renders from** | `DECLARE` |
| **New terms** | 0 |
| **Words** | 13 |

**On screen**

> ### DECLARE THE TARGET
>
> Name who you are hitting.
> Only figures you can legally reach will light up.

**Diagram** — `target-declare` · **interactive**
Board. The Swordsman is **BLACK solid**. Every legal target is **WHITE outlined** with a
**GOLD** ring; illegal targets stay **GREY**. Since this packet is `range: 0`, only a
figure in base contact lights. A thin gold line snaps from attacker to target on hover.

**If nothing is in reach** (`ACTION` tapped from 2″ out — a real path):

> ### NOTHING IS IN REACH
>
> This packet is melee. Your bases must touch.
> **No AP is spent.**

`[ BACK ]` → FB-04, `ap_left` unchanged. Illegal declarations are free — the player is
never punished for exploring.

**Buttons**

| Label | State | → |
|---|---|---|
| tap the goblin | enabled on legal targets | FB-A2 |

### FB-A2 · Roll

| | |
|---|---|
| **Renders from** | `ROLL`, `SUCCESS` |
| **New terms** | 1 — *Success* |
| **Words** | 16 |

**On screen**

> ### ROLL 3 DICE · 4+
>
> Every die that meets or beats **4** is a **Success**.
> Count them.

**Diagram** — `roll-dice` · animated, 0.9s
Three large dice tumble and settle. Dice ≥ 4 fill **GOLD** with a check; dice < 4 stay
white and dim. A running counter beneath: `SUCCESSES  2`. The dice count and success
number are read from the packet — **never hard-coded**.

**Buttons**

| Label | State | → |
|---|---|---|
| **ROLL** | enabled | animate → FB-A2b |

### FB-A2b · Read the Grade

| | |
|---|---|
| **Renders from** | `GRADE`, `GRADE_DISCRETE` |
| **New terms** | 1 — *Grade* |
| **Words** | 22 |

**On screen**

> ### GRADE 2
>
> Your Successes are your **Grade**.
> Read **only** that line. A higher Grade does not carry the lower ones.

**Diagram** — `grade-read`
The same packet card from FB-A1, now expanded. The reached line — `GRADE 2 · 1 Wound ·
Shove` — is **GOLD**, boxed, and full-opacity. **Grade 1 and Grade 3 are struck through in
GREY.** Model 2 discrete (`A·VI`, `B·5`) is taught by *striking out the lines you do not
read* — one image, no paragraph.

**Buttons**

| Label | State | → |
|---|---|---|
| **APPLY THE GRADE** | enabled | FB-A2c |

### FB-A2c · Armour

| | |
|---|---|
| **Renders from** | `ARMOUR`, `WOUND_TRACK` |
| **New terms** | 1 — *Armour* |
| **Words** | 16 |

**On screen**

> ### ONE SAVE PER WOUND
>
> The defender rolls its **Armour** — Light, **6+**.
> Unsaved Wounds land.

**Diagram** — `armour-save` · animated
One save die per incoming Wound, rolled **on the defender's side of the screen** — the
first time the tutorial shows a roll that is not the player's. A failed save flashes
**RED**; the wound track below the goblin steps `FINE → HURT`. Goblin A has 1 Wound, so
one unsaved Wound reads `FINE → ✕`.

**Buttons**

| Label | State | → |
|---|---|---|
| **APPLY WOUNDS** | enabled | resolve, `ap_left--`, `attack_used = true`, → **ROUTER-A** |

### ROUTER-A · no screen

Runs in `B·5` order — effects, then armour, then wounds, **then** Counter and Nerve.

| State | → |
|---|---|
| target reduced past its track | **LE-WOUND** (kill variant) → **LE-COUNTER** → ROUTER-N |
| wounds landed, target lives | **LE-WOUND** (hurt variant) → **LE-COUNTER** → ROUTER-N |
| no wounds landed | **LE-COUNTER** → FB-04 |

### ROUTER-N · no screen

| State | → |
|---|---|
| a friendly Square (Man/Beast) within **3″** of a slain or Broken friend | **LE-NERVE** |
| that figure went **Broken** | → **LE-TEMPERAMENT** |
| otherwise | FB-04 |

---

## 4.3 WAIT branch

### FB-W1 · Arm the Packet

| | |
|---|---|
| **Renders from** | `WAIT` |
| **New terms** | 1 — *armed* |
| **Words** | 17 |

**On screen**

> ### WAIT — 1 AP
>
> Choose a packet to trigger later.
> **Waiting ends this figure's activation.**

**Diagram** — `wait-arm` · two-frame, 1.2s
1. The `militia_sword` card lifts off the figure and slides into an **ARMED** slot beside
   the base — a gold-outlined empty rectangle that fills as the card lands.
2. The remaining AP pip **stays filled** and dims — the single most important image on this
   screen: *you still had AP, and you gave it up.*

**Brace and Overwatch do not appear.** Brace is Square-only *and* **provisional** (`B·9b`,
unratified). Overwatch needs a ranged packet the Swordsman does not have. Neither is
printed, neither is hinted.

**Buttons**

| Label | State | → |
|---|---|---|
| **ARM PACKET** | enabled | `ap_left--`, `activation_over = true`, → FB-99 |
| *back* | always | FB-04, no AP spent |

---

# 5 · Encounter lessons

A lesson fires **once** (`seen_lessons`), interrupts the flow, and returns to where it was
called from. Each page is one fact. Three facts is three pages, never one paragraph.

## 5.1 LE-ENGAGED — 3 pages · `ENGAGED`, `DISENGAGE`, `COUNTER`

**Fires:** `engaged_with` becomes non-null after a MOVE.

### 1 / 3 — the physical event

> **Your bases touched.**
> ### ENGAGED
> These two figures are now Engaged.

`engaged-contact` — the two bases meeting, **BLACK** and **WHITE**. Both **NOTCHES** rotate
to face each other with a **SMALL CURVED ARROW** on each. Contact edge glows gold. No band,
no measurement, no ruler — *"No measured band. If the bases touch, they're engaged."*

### 2 / 3 — the cost

> ### LEAVING COSTS 1 AP
> Spend **1 AP** to Disengage before you move away.

`engaged-disengage` — the engaged pair, a **GOLD** arrow leading the black base away, one
AP pip extinguishing on the arrow's tail.

### 3 / 3 — the danger

> ### CONTACT ALLOWS A COUNTER
> When you strike, the defender strikes back.

`engaged-counter-tease` — the same pair, a **GOLD** strike arrow out, a **RED** strike arrow
back. The return arrow is thinner. This is a *warning*, not the Counter lesson.

`[ CONTINUE ]` → FB-04

---

## 5.2 LE-COUNTER — 2 pages · `COUNTER`, `COUNTER_DYING`, `COUNTER_NO_LOOP`

**Fires:** after any ACTION-attack resolves. **Not optional.**

> **Why forced.** `B·9`: attacking a **free** figure *always* draws a Counter and pulls it
> into engagement. It fires on essentially every first attack in CUS. The original brief
> listed it as one of five options on a "what happened?" menu — that under-rates the single
> rule most likely to kill a beginner's figure on turn one.

### 1 / 2 — the strike back

> **You attacked a free figure.**
> ### COUNTER
> It turns, hits back, and is now engaged with you.

`counter-turn` — three frames, 2.0s. (1) black base strikes a white base that is **not yet
facing it**; (2) the white base's **NOTCH** rotates to face — **SMALL CURVED ARROW**; (3) a
**RED** strike arrow returns, and the goblin's 2 dice roll live against the Swordsman's
**Medium 5+** armour.

### 2 / 2 — the dying swing

> ### IT SWINGS EVEN AS IT DIES
> There is no limit on Counters. A Counter draws no Counter.

`counter-dying` — the goblin **RED** and falling, its strike arrow **still landing**. This
is the tutorial's one moment of real drama. Flagged in `rules.js` as
`cinematic: "the-dying-swing"` — the first cinematic plate to commission (§7).

`[ CONTINUE ]` → ROUTER-N

---

## 5.3 LE-WOUND — 2 pages · `WOUND_TRACK`

### 1 / 2

> **The blow landed.**
> ### MARK THE WOUND
> Step the figure along its track.

`wound-track` — `FINE → HURT → KO → DEAD` as four chips; the reached chip fills **RED**,
the rest stay **GREY**. Goblin A has one Wound, so the animation runs `FINE → ✕` and the
figure tips over.

### 2 / 2 — kill variant only

> ### IT IS DOWN
> Remove the figure. Its space is free again.

`wound-remove` — the base lifts away; a **DASHED** outline marks where it was; the lane
behind it clears.

`[ CONTINUE ]` → LE-COUNTER

---

## 5.4 LE-NERVE — 4 pages · `SHOCK`, `NERVE`, `MORALE`, `BROKEN`

**Fires:** Goblin B is 1.6″ from A. A dies. B is a Square, Creature Type Man → **shock**.

### 1 / 4 — the trigger

> **A goblin fell beside its friend.**
> ### THIS CAUSES SHOCK
> A Square tests Nerve when it is Wounded, or when a friend falls within 3″.

`nerve-shock` — Goblin A **RED** and down; a **THIN RING** of 3″ radius drawn from A; Goblin
B, inside the ring, lifts to **WHITE outlined**. Goblin C, outside, stays **GREY**. The ring
*is* the rule.

### 2 / 4 — the roll

> ### ROLL 3 DICE
> Count dice that meet or beat this figure's **Nerve** — **4**.

`nerve-roll` — three dice; ≥4 fills gold. The Nerve number is read from
`GOB_WARRIOR.stats.nerve`, never hard-coded.

### 3 / 4 — the reading

> ### READ THE SUCCESSES
>
> | **0** | **1–2** | **3** |
> |---|---|---|
> | step **DOWN** | **HOLD** | step **UP** |

`nerve-read` — three large outcome blocks; the one that occurred fills **GOLD**, the others
dim. Beneath, the morale track `STEADY → SHAKEN → BROKEN` with a marker sliding one step.

### 4 / 4 — Broken only

> **It broke.**
> ### HOW DOES IT BREAK?
> A Broken figure Routs by its **Temperament**.

`[ CONTINUE ]` → LE-TEMPERAMENT · else → FB-04

---

## 5.5 LE-TEMPERAMENT — 1 page · `TEMPERAMENT`

> **Reveal only this figure's result.** All five temperaments live in HELP and FULL
> REFERENCE. A beginner learns Cowardly because a coward broke in front of them.

> **This goblin is Cowardly.**
> ### IT FLEES
> A Cowardly figure Routs to its own table edge.

`temperament-cowardly` — the goblin **RED**, a **BIG ARROW** carrying it north off its own
board edge, a **DASHED** base left behind.

`[ CONTINUE ]` → FB-04 · `[ see all five ]` → FULL REFERENCE `TEMPERAMENT`

---

## 5.6 LE-SPRINT — 2 pages · `SPRINT`

**Fires:** `moves_this_activation === 2`.

### 1 / 2

> **You moved twice.**
> ### SPRINT
> A second MOVE in one activation is a Sprint.

`sprint-second` — two **DASHED** bases marking both origins, one continuous **GOLD** path
through all three positions, two AP pips extinguishing along it.

### 2 / 2

> ### YOUR ACTIVATION IS SPENT
> Both AP went to movement. There is no attack left.

`sprint-cost` — both pips hollow, the ACTION tile greyed. The tradeoff, shown not told.

`[ CONTINUE ]` → LE-IMPACT if contact, else FB-99

---

## 5.7 LE-IMPACT — 3 pages · `IMPACT`, `PUSH`, `INDENT`, `CRUSH`

**Fires:** a Sprint reaches a body.

### 1 / 3 — the event

> **You sprinted into an enemy.**
> ### IMPACT
> A Sprint that contacts a body resolves an Impact.

`impact-contact` — the black base arriving along its **GOLD** straight trajectory, the white
base at the point of contact, contact flash.

### 2 / 3 — the question the board answers

> ### CAN THE TARGET MOVE ASIDE?
> Shove it the minimum needed to clear your lane.

`impact-question` — the goblin line C · A · B with a **GOLD** lane driven through A, and
**GOLD** arrows probing left and right. **On this board the answer is NO** — C sits 1.6″
west and B 1.6″ east.

### 3 / 3 — the resolution the board produced

> **The bodies behind it blocked the shove.**
> ### INDENT
> They are carried forward. The line dents.

`impact-indent` — **DASHED** bases at all three goblins' origins, a **BIG ARROW** carrying
the line north, solid bases at the dented positions.

**Optional tap — never forced:** `[ THE OTHER TWO OUTCOMES ]`

| | |
|---|---|
| `impact-push` | **PUSH** — the lane was open, the body slides aside |
| `impact-crush` | **CRUSH** — a **HATCHED** wall blocks it, the mover jams and stops, `+2 ATTACK DICE` in gold |

Push and Crush are not screens in this run. They did not happen. Principle §6.

`[ CONTINUE ]` → FB-99

---

## 5.8 LE-ANGLE — 2 pages · `FLANK`, `REAR` · **not reachable in Part One**

Specified for completeness and for HELP mode. One activation cannot produce a flank on this
board — reaching a Square's unfaced arc requires it to be already engaged with someone
else, and the player has one figure.

### 1 / 2 — Flank

> **You struck a side it was not facing.**
> ### FLANK · +1 DIE

`angle-flank` — white base **NOTCH** pointing at a **GREY** figure it is already engaged
with; the **BLACK** attacker arrives on the unfaced side; `+1 DIE` in gold.

### 2 / 2 — Rear

> **You reached its back.**
> ### BACKSTAB · +2 DICE · NO COUNTER

`angle-rear` — same geometry, attacker at the rear; `+2 DICE` gold; a **RED** struck-through
counter-arrow.

---

# 6 · The complete branch table

Every edge in Part One. Nothing reachable is unlisted.

| From | Condition | To |
|---|---|---|
| start | — | FB-01 |
| FB-01 | BEGIN BATTLE | FB-02 |
| FB-02 | CHOOSE THIS FIGURE | FB-03 |
| FB-03 | SPEND AP | FB-04 |
| FB-04 | tap MOVE · `ap>0` | FB-M1 |
| FB-04 | tap ACTION · `ap>0 && !attack_used` | FB-A1 |
| FB-04 | tap ACTION · `attack_used` | **no navigation** — pulse the caption |
| FB-04 | tap WAIT · `ap>0` | FB-W1 |
| FB-04 | `ap===0 \|\| activation_over` | FB-99 |
| FB-M1 | FINISH MOVE | ROUTER-M |
| ROUTER-M | `moves===2` | LE-SPRINT |
| ROUTER-M | `engaged_with` | LE-ENGAGED |
| ROUTER-M | else | FB-04 |
| LE-SPRINT | contact made | LE-IMPACT |
| LE-SPRINT | no contact | FB-99 |
| LE-IMPACT | CONTINUE | FB-99 |
| LE-IMPACT | THE OTHER TWO OUTCOMES | inline expand, no navigation |
| LE-ENGAGED 3/3 | CONTINUE | FB-04 |
| FB-A1 | CHOOSE TARGET | FB-A1b |
| FB-A1b | tap legal target | FB-A2 |
| FB-A1b | no legal target | inline *NOTHING IS IN REACH* → FB-04, **no AP spent** |
| FB-A2 | ROLL | FB-A2b |
| FB-A2b | APPLY THE GRADE | FB-A2c |
| FB-A2c | APPLY WOUNDS | ROUTER-A |
| ROUTER-A | wounds landed | LE-WOUND |
| ROUTER-A | no wounds | LE-COUNTER |
| LE-WOUND | CONTINUE | LE-COUNTER |
| LE-COUNTER 2/2 | CONTINUE | ROUTER-N |
| ROUTER-N | friend fell within 3″ | LE-NERVE |
| ROUTER-N | else | FB-04 |
| LE-NERVE 3/3 | not Broken | FB-04 |
| LE-NERVE 4/4 | Broken | LE-TEMPERAMENT |
| LE-TEMPERAMENT | CONTINUE | FB-04 |
| FB-W1 | ARM PACKET | FB-99 |
| FB-W1 | back | FB-04, **no AP spent** |
| FB-99 | PASS TO OPPONENT | end card |
| *any screen* | ✕ exit | confirm → PLAY CUS landing |
| *any screen* | ‹ back | previous screen, **state rewound** |

**Back must rewind state.** If the player backs out of FB-A2c, the AP returns and
`attack_used` clears. A tutorial that cannot be un-done is a tutorial people abandon.

---

# 7 · Asset manifest for Part One

Ordered by production priority. Everything is inline SVG in `play/diagrams.js`, in the §0.2
token language. **The poster's existing SVG figures are the source — extend, do not
re-draw.**

| # | Asset | Type | Screen |
|---|---|---|---|
| 1 | `verbs-hub` | 3 icons | FB-04 |
| 2 | `move-drag` | interactive | FB-M1 |
| 3 | `engaged-contact` | static | LE-ENGAGED 1 |
| 4 | `counter-turn` | 3-frame | LE-COUNTER 1 |
| 5 | `ap-read` | static | FB-03 |
| 6 | `roll-dice` | animated | FB-A2 |
| 7 | `grade-read` | static | FB-A2b |
| 8 | `armour-save` | animated | FB-A2c |
| 9 | `wound-track` | 2-frame | LE-WOUND 1 |
| 10 | `nerve-shock` | static + ring | LE-NERVE 1 |
| 11 | `obj-establish` | static + pulse | FB-01 |
| 12 | `alt-focus` | static | FB-02 |
| 13 | `packet-choose` | card | FB-A1 |
| 14 | `target-declare` | interactive | FB-A1b |
| 15 | `engaged-disengage` | static | LE-ENGAGED 2 |
| 16 | `engaged-counter-tease` | static | LE-ENGAGED 3 |
| 17 | `counter-dying` | static | LE-COUNTER 2 |
| 18 | `wound-remove` | 2-frame | LE-WOUND 2 |
| 19 | `nerve-roll` | animated | LE-NERVE 2 |
| 20 | `nerve-read` | static | LE-NERVE 3 |
| 21 | `temperament-cowardly` | 2-frame | LE-TEMPERAMENT |
| 22 | `wait-arm` | 2-frame | FB-W1 |
| 23 | `pass-play` | 3-frame | FB-99 |
| 24 | `sprint-second` | static | LE-SPRINT 1 |
| 25 | `sprint-cost` | static | LE-SPRINT 2 |
| 26 | `impact-contact` | static | LE-IMPACT 1 |
| 27 | `impact-question` | static | LE-IMPACT 2 |
| 28 | `impact-indent` | 2-frame | LE-IMPACT 3 |
| 29 | `impact-push` | 2-frame | optional |
| 30 | `impact-crush` | 2-frame | optional |
| 31 | `angle-flank` | static | LE-ANGLE 1 |
| 32 | `angle-rear` | static | LE-ANGLE 2 |

**Cinematic plates — commission exactly one for Part One.** `the-dying-swing`, on
LE-COUNTER 2/2, behind a `SEE IT HAPPEN` ⇄ `SEE THE POSITION` toggle. The existing poster
already has the `CINEMA` object and the flip handler; reuse both. Nothing else in Part One
earns a plate.

---

# 8 · Hard-limit compliance

Brief §6, audited screen by screen.

| Limit | Status |
|---|---|
| ≤ 1 new term per screen | **1 exception:** FB-04 introduces MOVE · ACTION · WAIT together. Sanctioned — they are one three-part concept, and splitting them across three screens would teach that a figure picks a verb three times. Every other screen: 0 or 1. |
| ≤ 1 required decision | ✅ every screen |
| ≤ 1 cause-and-effect | ✅ |
| ≤ 35 instructional words | ✅ max is FB-A2b at 22 |
| ≤ 3 choice buttons | ✅ max is 3 (FB-04) |
| no vertical scrolling | ✅ enforced by the §0.3 anatomy |
| no exception unless happening | ✅ Reach, ranged, Circles, mounted, Large, Mob, shields, Brace, Shove, the other four temperaments, and Push/Crush are **all** withheld |
| no unlabelled icon on first use | ✅ every verb tile and every board marker is labelled |
| rule and its exception never share a screen | ✅ |

---

# 9 · Open questions this exposed

Building the flow against real data surfaced three things the kernel does not answer.
None blocks Part One; all three should be ruled on before Part Two.

## 9.1 Does an Impact resolve a PACKET, and whose, and at what cost?

`B·4` says *"Displacement is not damage… any Wound comes from the **PACKET** the Impact
resolves"* — but `B·3`/`B·4` never say **which** packet, whether it costs AP, or whether it
counts against **one attack per activation**. `B·4` then says a wall-Crush means *"the
Impact receives the appropriate bonus"* (the poster prints **+2 dice**), which implies the
Impact **is** an attack roll.

**Part One assumes:** a Sprint moves and shoves; **the blow is a separate ACTION.** Under
this reading the 2-AP Swordsman that Sprints has no attack left — a clean, legible
tradeoff, taught on LE-SPRINT 2/2. **If that is wrong, LE-SPRINT 2/2 and LE-IMPACT change.**

## 9.2 Does an Impact draw a Counter?

A Sprint into a **free** goblin makes contact and therefore engagement. `B·9` says a free
target **always** Counters. So a Sprint should eat a Counter — but `B·3` never says so, and
the poster's Counter panel is framed entirely around ACTION-attacks.

**Part One assumes:** yes — contact is contact, so the Impact draws the Counter. This
follows `B·9` literally and is the safer teach.

## 9.3 Small does not plow — so what does a Small goblin do to a Medium swordsman?

`B·4`: *"Small does not plow — it slips through without an ordinary Disengage."* The
Swordsman is **Medium** and the goblins are **Small**, so Medium-plows-Small is clean and
Part One is unaffected. But the reverse — a Small figure Sprinting into a Medium one — has
no stated resolution. Does it slip through and end behind? Does it stop? Does it bounce?

**Part One never produces this case.** Flagged for HELP mode, which will.

---

# 10 · Version labelling — the fix

Confirmed on disk, and it is worse than the brief supposed:

```text
play/HOW_TO_PLAY_v1_4.html   md5 52336c23614ecc6b8f35f2a03eb016bc
play/HOW_TO_PLAY_v1_5.html   md5 52336c23614ecc6b8f35f2a03eb016bc   ← byte-identical
```

Both files already carry `<title>CUS — How to Play v1.5</title>`. **The page is not stale —
the filename is.** The live URL is a duplicate of the current page under an old name.

**Fix — do not delete `v1_4`.** It is the link that has been shared.

1. `play/HOW_TO_PLAY_v1_5.html` stays canonical, and becomes **FULL COMBAT REFERENCE**.
2. `play/HOW_TO_PLAY_v1_4.html` is replaced by a 12-line redirect stub:
   `<meta http-equiv="refresh" content="0; url=HOW_TO_PLAY_v1_5.html">` plus a visible
   fallback link, for the case where a reader has JS and meta-refresh disabled.
3. `play/index.html` becomes **PLAY CUS** — the three doors — and takes over as the URL
   given out from now on.

---

# 11 · What Part Two owes this document

Not built here. Recorded so it is not re-litigated.

| Part Two teaches | Because Part One could not |
|---|---|
| the greyed ACTION gate | needs a 3-AP figure (§2.3) |
| Flank · Rear · Backstab | needs a second friendly figure (§5.8) |
| Reach | the Swordsman has none |
| Ranged — Precision · Regular · Multi-shot | no ranged packet on the board |
| Circles — faceless, unbreakable, Mob | one activation cannot teach two base types |
| End of round | correctly withheld (brief §3, Screen 2) |
| Push · Crush | did not happen on this board (§5.7) |
| the other four Temperaments | a Cowardly goblin broke; the rest are HELP-mode content |
| Shields · Brace · Shove | **provisional** — teach nothing unratified to a beginner |

---

*CUS · FIRST BATTLE SCREEN MAP v1.0 · rules source: KERNEL REBUILD v0.6 (SIGNED) · figure
and packet data: CUS_FACTIONS/data · generated presentation source: play/rules.js*
