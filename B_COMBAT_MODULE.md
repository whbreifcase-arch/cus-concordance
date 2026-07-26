# CUS — THE COMBAT MODULE
### v0.6 · the reference implementation · rebuilt 2026-07-23

> **What this is.** The Kernel (Document A) doing real work: physical conflict.
> Combat is the *reference* implementation — it exercises the most primitives.
> Everything here is a **Combat Module fact** and may be retuned; none of it is
> promoted to Kernel law (Law 12). `→ G·combat-is-not-the-kernel`
>
> **On "not."** Where the obvious reading of a rule is wrong, you'll see
> `→ G·<slug>`; the reasoning lives in **[Document G · Why Not](G_WHY_NOT.md)**.
>
> **Citation rule.** Every mechanic names the Kernel primitive it reads or
> writes, in brackets: `[Position]`, `[PACKET→Grade]`, `[Agency]`, `[State]`.
> If a mechanic can't cite one, it doesn't belong here (Law 14).
>
> **Translation.** Combat renames the three verbs:
> `MOVE→Advance · ACTION→Strike/Interact/Cast · WAIT→Brace/Overwatch`. The player
> reads the flavour; the system reads MOVE · ACTION · WAIT.

---

# 1 · Bases — physical information

The base *is* the label. Pick up the model and read it.

## Shape = type  `[Definition]`
```text
Circle = hero / avatar          Square = crew / commandable body
```
- **Circle** — hero/avatar. **Faceless** (no facing — can't be flanked). Never tests
  Nerve, never breaks.
- **Square** — crew. **Has a facing.** May test Nerve, may break.

> **One Circle per Banner — SIGNED (William, 2026-07-24 · scope clarified 2026-07-25).**
> A **Banner** fields **exactly one Circle: its Champion.** An **Army**, being many
> Banners (A · X), therefore holds **one Circle per Banner** — not one in total.
> Every other figure — sergeants, casters, monsters, all — is a
> **Square.** Only the Champion keeps full agency and is faceless/unbreakable; everyone
> else trades agency for the Square's mutual protection (facing, Brace, shields — and
> the risk of being flanked and broken).

## Size = class  `[Definition]` — SIGNED (William, 2026-07-24)
**Three classes**, read from the **footprint**. No Monstrous; no Cavalry as a class.
```text
Small · Medium · Large
```
| Class | Square | Circle |
|---|---:|---:|
| Small | 20 mm | 25 mm |
| Medium | 25 mm | 32 mm |
| Large | 40 mm | 40 mm |

A "monstrous" creature is simply a **Large** figure distinguished by its **traits**
(§14) — e.g. a plow-through-bodies trait. `→ G·traits-are-not-base-properties`

## Elongated = mounted  `[Definition]`
**Mounted is geometry.** An elongated base — an elongated Small, Medium, or Large —
communicates mounted geometry: **narrow frontage penetrates deeply; wide frontage
bulldozes broadly.** A mounted figure keeps its size class and **plows as one class
larger** (the lance, §4). Cavalry doctrine emerges from
`Role · Tempo · Tool · Temperament · PACKETs · geometry`.
`→ G·mounted-is-not-a-size-class`

## Tool set  `[Definition]` — SIGNED (William, 2026-07-24)
The Combat Module's Tool vocabulary — *how* a figure delivers Force — is a
**vibe-check** (ordinal classification, Law 10):
```text
Melee · Ranged · Hybrid
```
*Hybrid* = a figure that meaningfully delivers Force both in contact and at range.
A Melee figure may be Pressure, Anchor, or Utility. `→ G·tool-does-not-set-purpose`

---

# 2 · Movement  `[writes Position]`

Advance is combat's MOVE: choose a legal destination or trajectory, pay Agency,
change Position. Movement carries the usual domain aliases (Advance, Sprint,
Leap, Withdraw) — all MOVE.

- **Obstacles are paid inline** as part of one continuous MOVE (no
  stop-spend-move). Climbing/vaulting costs extra Agency per story `[Agency]`.
- Dropping one story is free and harmless; dropping further, or being displaced
  off an edge, resolves as an **Impact against the ground** (§3–4): the fall
  invokes a PACKET like any other collision `[PACKET→Grade]`. It is a Combat
  Module procedure, retunable, and owned here.

---

# 3 · Sprint & Impact  `[writes Position]`

```text
Sprint = continued MOVE
Impact = the contact that MOVE creates
```
**"Charge" is the name for a Sprint that qualified** (the 3″ threshold below) — a
description of a movement, not a verb you declare.
`→ G·charge-is-not-an-action`

> **When a Sprint contacts another body, resolve an Impact.**

The figure stays in its Sprint; **Impact** names the collision and its
resolution, not the movement producing it.

Conceptual reduction:
```text
Sprint through bodies  =  MOVE  +  N× Impact resolutions  +  Position changes
```

## The 3″ threshold — sprint becomes charge  `[Position]` — SIGNED (William, 2026-07-25)
Not every Sprint that touches something is a charge. **A Sprint becomes a charge
when it covers 3″ of uninterrupted straight run-up into contact.** The clean run
*is* the charge; below 3″ the figure simply arrives.

- **"Interrupted" means physical contact** — a body in the lane. A shot, a
  reach-strike, or any other triggered PACKET that fires while the figure is
  moving **resolves without interrupting**: getting hit on the way in is not
  getting stopped.
- **Interruption commits the charge where it happens.** The Impact resolves
  against whatever was actually struck, and the intended target beyond is
  fumbled. If ≥3″ of clean run was already covered when the interrupter was hit,
  *that* contact is itself a valid charge into the interrupter; if less, the
  figure halts there.
- This is why a **screen** beats a charge: deny the 3″ lane with terrain,
  spacing, or chaff and you deny the charge before a blow is struck.

The 3″ is a **threshold, not a distance budget.** It qualifies the contact; it
does not cap what follows — the plow that follows resolves under §4 geometry and
runs until the mover's Move/Agency is spent or it jams.

> Full governing spec: **[Document F · Continuous Clash Resolution](F_CLASH_RESOLUTION.md)**.

---

# 4 · The Push — geometry, not a number  `[writes Position]`

Two bases cannot share space. A moving base continues along its **straight
trajectory** and displaces contacted bases the **minimum** needed to clear its
path. Slide the models; don't measure. The cascade:

1. **Push** — shove the contacted body aside enough to clear the lane.
2. **Indent** — if bodies behind it block the sideways shove, carry them forward;
   the line dents.
3. **Crush** — if a **wall or obstacle** prevents clearance, the mover **jams and
   stops**, and the Impact receives the appropriate bonus (nowhere to go = it
   crushes).

**The Push writes Position.** Any Wound or state change comes from the **PACKET**
the Impact resolves `[PACKET→Grade]`. The wall-crush is the only place a blocked
shove feeds the hit. `→ G·push-is-not-damage`

> **"Push" = the charge plow.** The *weapon* displacement Effect is **Shove**
> (§9b). `→ G·shove-is-not-push`

Size gating across the three classes (Small · Medium · Large):
- **larger plows smaller** — always, charge or not;
- **same size plows only on a charge** (§3, the 3″ threshold met). A same-size
  body that arrives *without* a charge **jams and stops on contact.** ⚠ PROVISIONAL
  — this is the executable reading of "same-size plow grudgingly"; ratify in play;
- **Small does not plow** — it slips through without an ordinary Disengage;
- **Mounted (elongated) plows as one class larger** (the lance);
- a head-on clearing tie is the **mover's choice**;
- movement continues until Agency/Move is exhausted or the mover jams.

*A figure that should shove through bodies unchecked (the old "Monstrous") carries a
**trait** (§14) — e.g. `unstoppable` (only a wall stops it) — rather than occupying a
fourth size class.*

---

# 5 · PACKET resolution in combat  `[resolves PACKET → Grade]`

A combat PACKET may define: `dice · success_number · range/reach · area · cost ·
grades · effects`. It is **referenced, never copied** onto each weapon; the
ordering below is written **once, here**, not on every card.

Typical flow:
```text
declare target        [Position: legality]
→ verify legality
→ load modifiers      (position/facing/environment — prefer Position over numbers)
→ roll dice
→ count Successes     (each die ≥ success_number)
→ determine Grade     (highest Grade reached)
→ resolve Effects
→ roll Armour per Wound
→ apply surviving Wounds        [State]
→ resolve Counter / Nerve / aftermath   (owned procedures — §9, §10)
```

> **SIGNED (William, 2026-07-24): Model 2 — Discrete.** Read the **single** Grade
> you reached and resolve **only** the Effects written on that line. A higher Grade
> does **not** carry up lower Grades' Effects. Authoring rule: write each Grade line
> as a complete result; if an Effect should appear at several Grades, print it on
> each. No accumulation, no "best-Wound-plus-every-passed-Effect."

---

# 6 · Success Grades in combat

The result structure is the Kernel's **Success Grade** (Document A · VI). A combat
PACKET lists its Grades against a success count:
```text
GREATAXE — Dice 3 · Success 5+
  GRADE 1 — 1 Wound
  GRADE 2 — 2 Wounds
  GRADE 3 — 2 Wounds + Cleave
```
- **Success** — a die ≥ the PACKET's success number.
- **Grade** — how well the roll succeeded.
- **Effect** — Wound, **Shove**, Knockdown, Guard, Cleave, Execute, ignore-Armour, …
  the state change a Grade resolves `[State]`. *(The weapon effect is **Shove**, not
  "Push" — "Push" now names only the charge plow of §4. See §9b.)*

**Discrete (Model 2):** the Greataxe above restates "2 Wounds" at Grade 3 on
purpose — you read **only** the reached line, so any Effect meant to carry up is
written on each line. `→ G·grade-is-not-a-tier`

---

# 7 · Wounds & Armour  `[State]` — SIGNED (William, 2026-07-25)

**Wounds are a number, not a track.** A figure has a **Wounds** stat — how much
punishment it absorbs before it goes down. **The standard is 1 or 2**; it is a
**knob**, tuned per figure, and a Large monster or a Champion may carry more.

```text
Wounds : 2        ← Definition (on the card)
wounds_remaining  ← Instance (on the table)
```

```text
wounds_remaining > 0   →  standing (no state; read the number)
wounds_remaining = 0   →  KNOCKED OUT  or  DEAD    [State]
```

**Knocked Out** and **Dead** are genuine State — they change what the figure can
do. `→ G·wounds-are-not-a-track` · where the old track went:
[Document D](D_MIGRATION_MAP.md).

Which one a downed figure enters is decided by the
Effect that felled it, its Creature Type (§13), and the aftermath procedure — an
`execute` Effect kills outright; ordinary Wounds put a figure down.

## Armour
Armour rolls **one save die per incoming Wound**. Current spectrum (Combat facts,
**not** Kernel primitives — do not promote these numbers upward):
```text
None —      Light 6+      Medium 5+      Heavy 4+
```
A save that would worsen past 6+ can no longer save. **Each unsaved Wound
subtracts 1 from `wounds_remaining`.** A Grade reading "2 Wounds" rolls two saves
and subtracts what survives — so a 2-Wound figure drops to a clean Grade that a
3-Wound figure walks away from. That is the whole interaction; there is no track
to step down.

---

# 8 · Engagement & facing  `[Position]` — SIGNED (William, 2026-07-24)

**Bases touching = engaged.** No measured band — if two bases are in contact, the
figures are engaged, full stop. Engaging turns **Squares** to face each other;
**Circles are faceless** — a hero has no facing, so angle never matters to or from a
Circle.

**Only a melee ACTION resolved in base contact creates engagement.** A ranged
ACTION never engages, never turns the target, and never draws a Counter, however
close the shooter stands — shooting a figure across the table does not glue you
to it. Engagement is a contact relationship, not a targeting one.

A figure faces the enemy it is engaged with. Striking a **free** figure in contact
pulls it into engagement — it turns to face you and Counters (§9). A **Square
already engaged with another enemy** faces *that* foe, so a new attacker reaching
its **flank or rear** strikes an arc it isn't facing (a Flank/Backstab) and draws
no Counter. A **Circle**, being faceless, always Counters regardless of angle.

Leaving an engagement costs a **Disengage — 1 AP.**

**Reach is the exception to base-contact.** A Reach figure threatens a **1–2″ band**
and may strike a figure that tries to move past within that reach **without base
contact** — so you can't just walk by a spearman. A Reach strike from outside contact
is not engagement and draws **no Counter** (§9).

---

# 9 · Counter — a written trigger  `[PACKET → Reaction]` — SIGNED (William, 2026-07-24 · amended 2026-07-25)

Strike a figure in melee contact and it **Counters** — one melee PACKET back —
**and turns to face you; you are now engaged.** A **free (unengaged) target always
gets its swing** and is pulled into engagement with its attacker: the first
attacker on an open figure eats the Counter.

## A Counter is authored, not armed — SIGNED (William, 2026-07-25)
A Counter is a **Written Trigger** — a trigger clause carried inside a PACKET. The
weapon, or the condition, holds the wording that permits a counter-attack:
```json
"spear_thrust": {
  "trigger": { "on": "struck_in_melee_contact", "cost": "1 Reaction" }
}
```
If a figure's weapons and conditions carry no such clause, it does not Counter.
The Counter is a property of what you are holding and what state you are in — not
a universal reflex bolted onto every figure. This is why the Kernel needs no
`counter_x` economy (Document A · III, IV).

## It costs a Reaction — SIGNED (William, 2026-07-25)
**Every Counter spends one Reaction** (§12). That, and death, are the only limits:
- **No artificial cap.** A figure Counters every enemy that strikes it, and
  **Counters even as it dies** — the dying swing lands.
- **The cap is the pool.** Out of Reaction, out of Counters, however many enemies
  step up. A shieldman who has already intercepted has nothing left to swing with.
- **A Counter does not itself draw a Counter (SIGNED, William 2026-07-24).**
  `→ G·counter-is-not-an-attack`

Worked example — you strike a figure, engage, it spends its Reaction to Counter
and kills you; your body is shoved off; that figure is now free, **but has no
Reaction left this round** and will not Counter the next attacker who steps up.

**Ranged never draws a Counter** (§8): no contact, no engagement, no trigger.

The other ways to deny a Counter are positional:
- **Free target** → **Counters**, turns to face, becomes engaged with you. *(No, you
  can't safely walk up and stab a free figure — it turns and hits back.)*
- **Square already engaged with another enemy, struck on its unfaced flank/rear** →
  **no Counter.** It faces foe X; a new attacker reaching the arc it isn't facing gets
  the free side-shot. **Circles are faceless** → a Circle **always** Counters, from
  any angle.
- **Reach without contact** → **no Counter** (the reach striker is not glued).

---

# 9b · Shields, Brace & Shove  `[Position / State]` — SIGNED (William, 2026-07-24) · ⚠ PROVISIONAL

> **Provisional — ratify after the first game.** These three fell out of the same
> conversation and answer "how does a wall of shields actually work" without a
> "Shield Wall" skill. *Playing* decides whether the numbers hold.

## Squares trade autonomy for protection; Circles keep autonomy and stand alone.
This is the spine. **Brace, shields, and formation are Square technology** — a Square
gives up freedom (locked facing, breakable morale, no independent will once it
Routs) in exchange for mutual protection. A **Circle keeps full autonomy and stands
alone**: faceless, never braces, never breaks.

`→ G·agency-is-not-autonomy`

A "shield wall" is therefore **emergent geometry**: Squares standing
shoulder-to-shoulder, facing the same way, are a wall because of where they stand.
There is no Shield Wall skill. `→ G·brace-is-not-an-ability`

## Shield — a trait, and an *intercept* reaction  `[Trait → Reaction]`
A **shield** is gear (a Trait). Beyond the obvious (it comes with armour), it carries a
written trigger: **spend 1 Reaction to consume an ACTION packet aimed at a friendly
within 1″ — take the hit yourself instead.** *"No, I'll take that one over here."*
- **Costs one Reaction** (§12), the same pool a Counter spends.
- You must **declare it in the moment, before the packet resolves.** Miss the window,
  miss the save — it is an act of attention, not an automatic shield.
- The **interceptor's own Armour** rolls against it; unsaved Wounds land on **him.**
- **No Counter** — he was not the one attacked, and he isn't in contact.
- **No artificial cap — SIGNED (William, 2026-07-25).** Nothing limits interception
  except the two things that already limit it: **he spent his Reaction**, and **he can
  die eating the hit.** A shieldman with Reaction left may take a hit for his line;
  once spent, he is a body like any other, and a good shot or a big Grade drops him
  and the wall opens. Do not add a per-round intercept limiter on top — that is what
  the Reaction pool *is*.
- **A universal reaction, not a defender-only one.** A shield escorting a charging
  figure protects it exactly as a shield in a standing line protects its neighbour
  (Document F).
- Works **regardless of facing** (even while Braced) — reaching the shield sideways to
  cover a mate is the one thing that still functions to your flank.
- Intercepts **melee and ranged alike** (a shield eats arrows). Since it costs the
  Reaction and every intercept is a real hit on the shieldman, it is self-limiting.
  *(⚠ If ranged feels gutted in play, restrict to melee.)*

## Brace — a fixed-facing stance  `[WAIT — Square only]`
**Brace is universal — any Square may do it, and it is never printed on a card.**
(Only the Champion is a Circle, and Circles can't Brace.) `→ G·brace-is-not-an-ability`
It is a WAIT — **1 AP, ends your activation, lasts until your next activation** —
that **locks your facing** and turns you into a wall in **one direction**:
- **+1 die** attacking into your **front arc**; **enemies attacking your front roll
  −1 die.** A braced front is brutal both ways.
- **The price: you cannot turn.** Anything striking your **flank or rear gets in free
  and you do not Counter it** — a braced Square concedes its sides entirely.
- **Circles cannot Brace** — a faceless base has no facing to fix (falls out of B.1).
- **Shove breaks Brace** (below): levered out of position, the stance ends.

> **Brace grants no Reaction — SIGNED (William, 2026-07-25).** Bracing does **not**
> refill, add to, or substitute for the Reaction pool. What it buys is **hard
> bonuses and step-ups** — the dice swing above, and any step-up an effect writes
> onto the stance. A braced figure that has spent its Reaction still cannot Counter.
> Brace makes you *better*, not *more available*.

## Overwatch — pay AP for a better trigger  `[WAIT]` — SIGNED (William, 2026-07-25)
Overwatch is the clean Kernel case of WAIT (Document A · III): **spend 1 AP to arm a
chosen PACKET against a declared trigger.** It exists because your written triggers
(§9) may not be the response you want — Overwatch buys you a *better* PACKET than the
situation would otherwise hand you.

**It still spends the Reaction when it fires.** The AP bought the upgrade; the
Reaction buys the right to act on someone else's activation. An armed Overwatch on a
figure with an empty pool **does not resolve** — arming is not permission.

```text
Overwatch:  1 AP now (arm the better PACKET)  +  1 Reaction later (fire it)
Counter:    0 AP     (written into the weapon) +  1 Reaction later (fire it)
```

## Shove — the weapon displacement effect (renamed from "Push")  `[Position]`
The Grade effect once called **Push** is now **SHOVE**, so "push" is free for ordinary
language and the §4 charge-plow keeps the word cleanly.
```text
SHOVE: move the target directly away from you, up to X", ending no more than Y"
       from you.  Default X = Y = 1".  (X and Y are tunable per weapon/effect.)
```
- In **contact** → knocked back to ~1″. Already ~1″ out (a Reach band) → he barely
  moves; you can still swipe him, but a spear **holds a foe at bay, it does not launch
  him across the table.**
- A Shove against a **Braced** figure **breaks the Brace** instead of merely nudging it
  — this is the counter to a shield wall: **shove the wall out of line, then hit the
  gap.** Every polearm and Shove effect now has a job beyond flavour.
- Distinct from the **charge Push→Indent→Crush** plow (§4), which is unchanged.

## The consequence to notice
Adjacency now does three things at once: shoulder-to-shoulder makes a wall (harder to
turn, shields covering each other), lets mates pile dice via Mob (§ Position), **and**
packs everyone inside each other's cascade. Tougher, deadlier, and it breaks all at
once. *That is not a problem to solve — that is the game.*

---

# 10 · Nerve, morale & break  `[State / Temperament]`

**Morale track — SIGNED (William, 2026-07-24): three states** (like everything else,
in threes).
```text
Steady → Shaken → Broken
```
- **Squares test Nerve; Circles do not** — and Circles never break. `[Definition: shape]`
- A failed test steps a Square **down** the track (Steady → Shaken → Broken) `[State]`.
- **Broken = it Routs**, behaving by its **Temperament** (table below).
- **Rally** steps a figure back **up** the track (toward Steady).
- **Creature Type** may alter the branch.

**Temperament behaviour — SIGNED (William delegated → designed, 2026-07-24).** What a
figure does when **leaderless** (its AI fallback) and when it goes **Broken (Routs)**:

| Temperament | Leaderless — it… | On Broken (Rout) — it… |
|---|---|---|
| **Cowardly** | keeps distance, avoids danger, strikes only with the odds | flees to its own table edge |
| **Resolute** | holds or pursues the objective | falls back toward its leader / the objective (does not flee outright) |
| **Aggressive** | advances on the nearest enemy | one last reckless advance at the nearest enemy |
| **Protective** | guards / stays close to the nearest ally | retreats to the nearest ally |
| **Ravenous** | attacks the nearest figure, any side | turns **Wild** — attacks the nearest figure, friend or foe |

**The Nerve test — SIGNED (William delegated → designed, 2026-07-24).**

*Who tests.* Only **Squares** of Creature Type **Man** or **Beast.** Circles never
test (heroes hold); **Spirit** and **Construct** never test (fearless).

*Triggers — a shock.* A Square tests Nerve the moment it suffers a shock:
- it **loses a Wound to a hostile ACTION and is still standing**
  (`wounds_remaining > 0`, §7), **or**
- a **friendly figure within 3″** is slain, Knocked Out, or goes **Broken.**

One test per shock. A PACKET may also force a test through a **Terror Effect.**

*The roll — in threes.* Roll **3 dice**; each die **≥ the figure's Nerve** value is a
success. Read the successes against the morale track:
- **0 successes** → step **down** one state (Steady → Shaken → Broken);
- **1–2 successes** → **hold** (no change);
- **3 successes** → step **up** one state (rally through it: Shaken → Steady).

**Broken → the figure Routs** by its Temperament (table above). **Rally** (a leader's
ACTION) also steps a figure **up** one state. The test reads like every other roll in CUS
— a small pool, a success number, count successes — so nothing new is learned.

---

# 11 · Formations — descriptive  `[Position]`

> **Formations are descriptive.** Players maintain the declared shape as closely as
> practical given Position, terrain, and contact.

A Formation Definition holds only: `Name · Picture · one sentence of intent`.
- **Advance** *translates* a shape (moves the group along a route).
- **Reform** *changes* a shape.

Both reduce to **existing verbs and Position changes** (Law 11).
`→ G·formations-are-not-prescriptive`

---

# 12 · The round — alternation & the two pools  `[Agency / Reaction]`

Combat's activation model:
```text
Side A activates one Figure → Side B activates one Figure → repeat until exhausted.
```
If one side runs out of eligible Figures, the other resolves its remainder one at
a time. Wild/uncontrolled figures resolve afterward per the owning procedure.
Alternation is **attention management** — a camera that directs focus to the
hottest fight. `→ G·alternation-is-not-initiative`

## The Reaction budget — SIGNED (William, 2026-07-25)
Reaction is combat's second Resource (Document A · IV) — what a figure may spend
during **someone else's** activation. It is budgeted like AP:

```text
Square (every figure)  →  1 Reaction
Circle (Champion/hero) →  2 Reactions
```

- **One pool, all triggers.** Counters (§9), shield intercepts (§9b), reach
  strikes (§8), and armed Overwatch (§9b) all draw from the same pool. There is no
  separate allowance per effect type.
- **Never paid from AP, never converted.** The pools do not exchange.
- **Refresh:** a figure's Reaction pool refills at the **start of its own
  activation**, alongside its AP. Spend it before your next activation and you are
  defenceless out of turn until then — which is exactly the resource the whole
  pre-contact game is fought over (Document F, *Preparation Matters*).
- **An armed WAIT expires** when the figure next activates, at the same moment.

## Round procedure
```text
1. Sides alternate single Figure activations.
2. On activation: refresh that Figure's AP and Reaction; expire its armed WAIT.
3. It spends AP on MOVE / ACTION / WAIT.
4. Triggers fired by others' activations spend Reaction as they occur.
5. Round ends when neither side has an eligible unactivated Figure.
```
Inside a clash, resolution runs in movement increments rather than whole moves —
see **[Document F · Continuous Clash Resolution](F_CLASH_RESOLUTION.md)**. The
pools above are unchanged by it; the clash is a cadence, not an exception to the
economy.

---

# 13 · Creature Type in combat  `[Definition]`

```text
Man · Beast · Spirit · Construct
```
Creature Type governs combat's **morale, mending, and targeting** relationships
(e.g. who tests Nerve, who can be healed, who never breaks) and decides whether a
downed figure goes **Knocked Out or Dead** (§7) — a Construct is wrecked, a Spirit
is dispersed, a Man may be dragged off the field. These branches are Combat Module
procedures, owned here and retunable. Creature Type is **what a figure
is**; its **Archetype** (Knight, Berserker, Assassin…) is *who* it is — a readable
`Role + Tool + signature` combination, never confused with type.

---

# 14 · Traits — referenced passive Definitions  `[Definition]` — SIGNED (William, 2026-07-24)

Always-true properties a figure carries — **Flying, Fearless, Amphibious, Reach,
Shield, Unstoppable, …** — are **Traits: referenced passive Definitions**
(Option B). A Trait is defined **once** and referenced by ID on a figure, exactly
like a PACKET but **passive** — it is never an ACTION/WAIT-resolved effect and never
holds runtime state (Law 5). The player-facing word is **trait**.
```json
{ "trait_id": "reach" }        { "trait_id": "unstoppable" }
```
A figure lists its `traits: [ ... ]`. A Trait resolves nothing — that is what makes
it passive. **Reach** is a Trait (and/or a PACKET property).
`→ G·reach-is-not-a-role`

## Base properties live in `base` — one owner (Law 1)
`size_class` and `mounted` are **base facts** (§1), read off the footprint:
```json
"base": { "size_class": "Large", "mounted": false, "shape": "square" },
"traits": [ "unstoppable", "reach" ]
```
A "monstrous" figure is a **Large base carrying `unstoppable`** (plow through
bodies, only a wall stops it — §4). `→ G·traits-are-not-base-properties`

---

# 15 · Combat presentation  `[Presentation]`

What the player sees is translation, never a parallel mechanic:
```text
player:  Advance · [weapon] "Spear Thrust" · GRADE 1/2/3 · Brace
system:  MOVE   · ACTION packet_id:spear_thrust · Grade · WAIT (armed packet)
```
Floating table state shows **Instance** only (Position, Wounds, Agency left,
conditions, an armed WAIT) — never the Definition's fixed stats, which live on the
card.

---

# 16 · What this module owes the Kernel

Every section above either writes **Position**, resolves a **PACKET** into a
**Grade**, spends **Agency**, changes **State**, or reads a **Definition** axis
(Role · Tempo · Tool · Temperament · Creature Type). Nothing here invents a
parallel universal action, and nothing stores runtime state in a Definition or a
PACKET (Laws 5, 11, 14). Every ruling this module rests on is signed and recorded
in **[Document E · Decision Register](E_OPEN_DECISIONS.md)**; the clash cadence it
defers to is **[Document F](F_CLASH_RESOLUTION.md)**. Items still marked
**⚠ PROVISIONAL** (§4 same-size plow, §9b shields/Brace/Shove) are signed rules
awaiting ratification *in play* — not open questions.
