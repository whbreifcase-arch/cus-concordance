# CUS — THE COMBAT MODULE
### v0.6 · the reference implementation · rebuilt 2026-07-23 · **Reaction struck 2026-07-27**

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
> **Translation.** Combat renames two of the three verbs:
> `ACTION→Strike/Interact/Cast · WAIT→Brace/Overwatch`.
> **MOVE stays MOVE** — SIGNED (William, 2026-07-25). The old *Advance* alias is
> retired: re-skinning the most-used verb in the game bought nothing and made
> every movement rule read twice. Sprint, Leap and Withdraw survive as flavour for
> *kinds* of MOVE, not as a rename of the verb itself.

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

**MOVE is MOVE.** Choose a legal destination or trajectory, pay Agency, change
Position. *Sprint · Leap · Withdraw* name **kinds** of MOVE — they are not
separate verbs and not a rename.

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
grades · effects · provokes · trigger`. It is **referenced, never copied** onto each
weapon; the ordering below is written **once, here**, not on every card.

Two of those fields point in opposite directions, and it is worth naming them apart:
```text
trigger    what this packet does when its HOLDER is struck   (the Counter it throws)
provokes   whether resolving this packet lets the TARGET Counter
```

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

## Fists — standard equipment — SIGNED (William, 2026-07-25)
**Every figure carries `fists`.** It is not printed on a card, not bought, and never
lost. It is a real melee PACKET — weak, always legal in contact, and carrying the
Counter trigger like any other weapon.

```json
"fists": { "dice": 1, "success": 5, "grades": { "1": "1 Wound" },
           "provokes": true,
           "trigger": { "on": "struck_in_melee_contact" } }
```

The point is that **the floor is never zero.** A caster out of mana, a spearman with
an enemy on his base, a shieldman who dropped his shield — none of them are helpless
statues. They are in the fight, badly.

> **This is what makes the Counter universal.** Because every figure always holds a
> packet with a counter trigger, "strike a figure in contact and it Counters" is
> true without exception. Nothing *costs* him the answer; what denies it is where
> you are standing (§9). `→ G·support-units-are-not-defenceless`

## `provokes` — the striking packet decides — SIGNED (William, 2026-07-27)
Whether a strike draws a Counter is a property of **the packet doing the striking**,
declared once in the packet rather than argued case by case in prose:

```json
"backstab":     { "provokes": false }     // he never saw it
"spear_thrust": { "provokes": false }     // not_in_contact — nothing to answer from
"longsword":    { "provokes": true }      // the default, printed for clarity
```

**Default: `true` for a melee packet resolved in base contact, `false` for everything
else.** A ranged shot, a reach strike, an Impact, a heal — none of them provoke,
because none of them is a man in contact hitting you. `provokes: false` on a melee
packet is a **real, priced advantage** and must be authored deliberately.

*(This is why the assassin needs no assassin rule: he carries a packet that does not
provoke, and the Counter section below stays four lines long.)*

## `not_in_contact` — the standing constraint — SIGNED (William, 2026-07-25)
A packet may declare that it **cannot be resolved while bases are touching.** It is
the one constraint that keeps long weapons and shooting honest:

```text
Reach weapons  — not_in_contact by definition (§8)
Ranged weapons — not_in_contact BY DEFAULT
```

**Most ranged packets carry it.** You do not shoot a bow with a man on your base;
you drop it and swing. **Exceptions are authored, not assumed** — a wrist crossbow,
a hand-flamer, a spell cast at point blank may omit the constraint, and that omission
is a real, priced advantage. If a ranged packet is silent, it has the constraint.

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

## Finishing the downed — SIGNED (William, 2026-07-25)
**A Knocked Out figure that is hit is killed. It rolls no Armour.**

Armour protects the standing and nothing else. A body on the ground is not a
defender, it is a task — and the task costs somebody an activation.

- The field does not go quiet when the line breaks. Someone has to **walk the field
  and finish people**, and every one of those is AP not spent winning.
- Heavy 4+ buys you nothing once you're down, so **the armour arms race has a
  ceiling** — you cannot armour your way out of being dropped.
- Whether your Champion is finished in the minute after he falls is the stake that
  **carries between games.** This is the hinge the campaign layer hangs on.

*(A downed body is still a body: it occupies its base and participates in the
Push → Indent → Crush cascade (§4). A field of the fallen fouls the next charge lane.)*

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

> **Facing is what caps the Counter — SIGNED (William, 2026-07-27).** This paragraph
> is now load-bearing. A Square answers **the face**: whatever comes at its front
> arc gets answered, every time, and everything that reaches its flank or rear gets
> in free. Surround a spearman with four men and he does not run out of swings — he
> runs out of **directions.** Three of those four are behind his shoulder.
>
> A **Circle** answers everybody from every angle. That is what the Champion's old
> second Reaction was clumsily trying to say, and it says it better as geometry:
> *a hero has no back.*
>
> So the answer to a shield wall is not to drain it. It is to **get around it.**
> `→ G·a-pool-is-not-a-position`

Leaving an engagement costs a **Disengage — 1 AP.**

## Reach — the `not_in_contact` constraint — SIGNED (William, 2026-07-25)
A Reach packet strikes out to its stated **X″** and **cannot be resolved while the
bases are touching.** That is the whole rule: not a measured dead-zone band, but a
**packet constraint** — the same shape as range, LoS or cost.

```json
"spear_thrust": { "reach": 2, "constraints": ["not_in_contact"] }
```

- **Outside contact, inside X″** → the spear works. You cannot simply walk past a
  spearman.
- **Bases touching** → that packet is illegal. The spearman is holding a weapon he
  cannot use at this distance, so he swings **Fists** (§5) like anyone else.
- A Reach strike from outside contact **is not engagement** and draws **no Counter**
  (§9) — the reach striker is not glued to anything. It carries `provokes: false`
  for the same reason (§5).
- When it fires on someone else's activation it **costs nothing** — but it fires
  **once per occurrence**, and *a movement is one occurrence*: a figure crossing the
  spearman's band is **one** poke, whether the clash resolves that crossing in one
  move or six half-inch increments (Document F). You cannot slice a run into
  free strikes. — SIGNED (William, 2026-07-27)

> **This is why depth wins.** A rank-2 spearman is touching nobody, so his spear is
> always legal; a front-rank spearman in contact is punching. Spear lines need a
> front rank — which is exactly what the sim measured, and now it falls out of one
> constraint instead of a special case.

`not_in_contact` is **reusable** — any packet may carry it (see §5, ranged).

---

# 9 · Counter — a written trigger  `[PACKET → Written Trigger]` — SIGNED (William, 2026-07-24 · amended 2026-07-25 · **2026-07-27**)

Strike a figure in melee contact and it **Counters** — one melee PACKET back —
**and turns to face you; you are now engaged.** A **free (unengaged) target always
gets its swing** and is pulled into engagement with its attacker: the first
attacker on an open figure eats the Counter.

**This is universal and it costs nothing.** Because every figure carries **Fists**
(§5) and Fists carry the counter trigger, no figure is ever without a legal Counter.
There is no pool, no budget, and no per-round allowance.

## A Counter is authored, not armed — SIGNED (William, 2026-07-25)
A Counter is a **Written Trigger** — a trigger clause carried inside a PACKET. The
weapon, or the condition, holds the wording that permits a counter-attack:
```json
"spear_thrust": {
  "trigger": { "on": "struck_in_melee_contact" }
}
```
The Counter is a property of **what you are holding** — not a universal reflex
bolted onto the figure. In practice every figure always has one, because **Fists**
are standard (§5); what varies is how badly it hurts. A caster who Counters with
fists and a knight who Counters with a longsword are running the same rule.

This is why the Kernel needs no `counter_x` economy (Document A · III, IV) — and,
since 2026-07-27, no Reaction economy either.

## The four limits — SIGNED (William, 2026-07-27)
A Counter is free. What stops one is never a number:

```text
CONTACT    no melee base contact → no Counter.  Ranged and Reach are out (§8).
FACING     an engaged Square answers its FRONT arc and concedes flank and rear.
           A Circle is faceless and answers everyone.                     (§8)
AUTHORING  the striking packet carries `provokes: false` → no Counter.     (§5)
DEATH      a dying figure gets its swing, and then it is over.
```

- **No artificial cap.** A figure Counters every enemy that strikes a face it is
  actually presenting, and **Counters even as it dies** — the dying swing lands.
- **A Counter does not itself draw a Counter (SIGNED, William 2026-07-24).**
  `→ G·counter-is-not-an-attack`
- **One Counter per strike.** Each incoming strike is one occurrence of the trigger
  and draws one answer — not one per attacker, not one per round.

Worked example — you strike a figure head-on, engage, it Counters and kills you;
your body is shoved off; that figure is now free and facing your corpse. **The next
man who steps up gets answered too, if he steps up in front.** Come at the shoulder
instead and he never sees you: same figure, same round, different geometry.

> **What this costs you, honestly.** You can no longer *spend* a shield wall down
> with chaff before landing the real blow — there is nothing to spend. The answer
> to a wall is now **envelopment**: deny the front, take the flank, and the Counter
> was never in the equation. That trade was made deliberately (Document E ·
> `reaction-struck`).

**Ranged never draws a Counter** (§8): no contact, no engagement, no trigger.

## Simultaneous death — both die — SIGNED (William, 2026-07-25)
If your ACTION kills the target and its Counter kills you, **both figures die.**
There is no initiative tiebreak, no "attacker resolves first," no survivor.

The dying swing lands because it was already thrown. Trading your life to take
someone with you is a legal, sometimes correct play — and there is no such thing as
a "spent" enemy any more. **Everyone facing you can answer.** Pick your angle.

The other ways to deny a Counter are positional:
- **Free target** → **Counters**, turns to face, becomes engaged with you. *(No, you
  can't safely walk up and stab a free figure — it turns and hits back.)*
- **Square already engaged with another enemy, struck on its unfaced flank/rear** →
  **no Counter.** It faces foe X; a new attacker reaching the arc it isn't facing gets
  the free side-shot. **Circles are faceless** → a Circle **always** Counters, from
  any angle.
- **Reach without contact** → **no Counter** (the reach striker is not glued).
- **A packet authored `provokes: false`** → **no Counter** (§5). The one non-positional
  denial, and it must be written on the packet and paid for in what the packet costs.

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

## Shield — a trait, and an *intercept*  `[Trait → Written Trigger]`
A **shield** is gear (a Trait). Beyond the obvious (it comes with armour), it carries a
written trigger: **consume an ACTION packet aimed at a friendly within 1″ — take the
hit yourself instead.** *"No, I'll take that one over here."*
- **Costs nothing** — like every Written Trigger since 2026-07-27 (§9).
- You must **declare it in the moment, before the packet resolves.** Miss the window,
  miss the save — it is an act of attention, not an automatic shield.
- The **interceptor's own Armour** rolls against it; unsaved Wounds land on **him.**
- **No Counter** — he was not the one attacked, and he isn't in contact.
- **The cap is that he dies — SIGNED (William, 2026-07-25 · restated 2026-07-27).**
  Nothing limits interception except the two things that were always the real limits:
  **he must be within 1″ of the target**, and **every intercept is a live hit on his
  own body.** A shieldman may hold his line as long as he can stand it; a good shot
  or a big Grade drops him and the wall opens. Do not add a per-round limiter on
  top — attrition *is* the limiter, and it is the honest one.

  > ⚠ **This is the item to watch in play.** It was the Reaction pool that quietly
  > held intercepting to roughly once per figure per clash. With the pool gone, a
  > Heavy-armoured shieldman standing over a caster can eat several packets before
  > he falls. That is the intended reading and it is under the §9b provisional flag.
  > If it plays out badly, the fix is **1″ and facing**, not a new pool.
- **A universal reaction, not a defender-only one.** A shield escorting a charging
  figure protects it exactly as a shield in a standing line protects its neighbour
  (Document F).
- Works **regardless of facing** (even while Braced) — reaching the shield sideways to
  cover a mate is the one thing that still functions to your flank.
- Intercepts **melee and ranged alike** (a shield eats arrows). Every intercept is a
  real hit on the shieldman, which is the whole of its self-limiting.
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

> **What Brace buys is quality — SIGNED (William, 2026-07-25 · restated 2026-07-27).**
> **Hard bonuses and step-ups**: the dice swing above, and any step-up an effect
> writes onto the stance. It does not make a figure *more available* to answer —
> nothing does, because availability is no longer rationed. Brace makes you
> **better at the front you chose**, and worse everywhere else.

## Overwatch — pay AP for a better trigger  `[WAIT]` — SIGNED (William, 2026-07-25 · amended 2026-07-27)
Overwatch is the clean Kernel case of WAIT (Document A · III): **spend 1 AP to arm a
chosen PACKET against a declared trigger.** It exists because your written triggers
(§9) may not be the response you want — Overwatch buys you a *better* PACKET than the
situation would otherwise hand you.

**Arming is permission.** The AP is the whole price; when the trigger fires, the
packet resolves. *(The old rider — "it still spends the Reaction, and an armed WAIT
with an empty pool does not resolve" — is **struck**. There is no pool to be empty.)*

```text
Overwatch:  1 AP  →  arm a PACKET of your choosing, and it fires
Counter:    0 AP  →  whatever the weapon already says, and it fires
```

**The two WAITs are the whole of paid out-of-turn capability.** Brace buys a better
front; Overwatch buys a better answer. Everything else that resolves on someone
else's activation is a Written Trigger, and Written Triggers are free.

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
> **Breaking them beats killing them — SIGNED (William, 2026-07-25).** The morale
> track is deliberately a **ratchet**: Nerve only tests on a *shock*, so a Shaken
> figure in a quiet corner does not drift back to Steady on its own, and a Routing
> figure runs *away* from the shocks that might test it. Only **Rally** — a leader's
> ACTION — reliably walks a figure back up.
>
> That is the design, not a gap. Pressure is cheaper than attrition; a broken enemy
> costs you nothing further and a dead one cost you every wound you had to land.
> It also makes killing the leader a *strategy* rather than a stat-check, because
> the leader is the recovery valve. `→ G·morale-is-not-attrition`

- **Squares test Nerve; Circles do not** — and Circles never break. `[Definition: shape]`

> **This law rests on RANK, not control — SIGNED (William, 2026-07-26).** Circles
> do not test because they are **exceptional**: heroes and champions, whoever is
> running them. **Enemy Circles do not test either.** They are not exempt because
> a player would object to being told his hero fled; they are exempt because that
> is what a champion *is*.
>
> *(Contrast Story's sacred-figure law, which rests on **control** — a played
> figure can never be Moved, but an NPC Circle can. Same word, two different
> bases, both now named. `→ G·rank-is-not-control`)*

## When an enemy champion breaks — SIGNED (William, 2026-07-26)
A Circle never breaks **by dice**. It breaks by **a prewritten trigger** — a
Written Trigger (A · XIV) authored onto that figure in advance, firing on its own
condition with nobody's thumb on it.

```text
NO TRIGGER WRITTEN  →  he fights to the end.
```

That is the safe default and it is correct for most enemies. Write one for the
champions.

> **Why this is better than a die roll.** A champion who breaks because the dice
> said so is arbitrary. A champion who breaks **when his brother falls** is a
> story — and players can work out what breaks a man and go do it. Enemy Circles
> stop being damage sponges and become puzzles.
>
> Note what the trigger *is*: a written condition, authored ahead of time, firing
> unprompted. **That is the same object as a campaign hook.** One authoring
> format covers both. `→ G·a-break-trigger-is-a-hook`
>
> Make it Temperament-shaped. A **Protective** break is not fleeing — he quits
> the fight to put himself between you and the small ones, and you take the room
> to find him standing over children with empty hands.
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

# 11 · Formations & Form Up  `[Position / Agency]`

> **Formations are descriptive.** Players maintain the declared shape as closely as
> practical given Position, terrain, and contact.

A Formation Definition holds only: `Name · Picture · one sentence of intent`.
Two operations, both reducing to existing verbs and Position changes (Law 11):
- **MOVE** *translates* a shape — the group travels, keeping its form.
- **Reform** *changes* a shape.

`→ G·formations-are-not-prescriptive`

---

## FORM UP — the group MOVE — SIGNED (William, 2026-07-25)

**Only a Sergeant may call Form Up.** This is the Fireteam's reason to exist
(A · X — the Sergeant supplies coordination and formation handling). A Circle
**cannot** call or join one: the Champion keeps his autonomy and stands alone
(§9b). Kill the Sergeant and the squad can no longer form up at all.

```text
FORM UP  — the Sergeant's procedure

1. DECLARE   The Sergeant names every unactivated friendly figure within 4″.
             Any of them may decline; joining is never forced.
2. SHAPE     The Sergeant places the joiners in a formation of its choosing.
3. PAY       Every participant — the Sergeant included — spends 1 AP,
             and is MARKED ACTIVATED for the round.        [Agency]
4. MOVE      They all MOVE at once, as one body, keeping shape.   [Position]
5. DECLARE   Before contact, each figure states exactly what it will
             strike and where it will Shove. Explicitly. Out loud.
6. RESOLVE   Contact resolves under Continuous Clash (Document F):
             increments, then every legal reaction, then the next increment.
```

### What the 1 AP buys
**The whole formation action.** One point covers that figure's MOVE, its attacks,
and its Shoves. It does not touch what the figure can *answer* with — a formed-up
figure still Counters and still intercepts with a shield, because triggers are free
and were never part of the activation (§9). What joining costs is the activation
itself, and that is the entire trade.

### Joining spends your activation
A figure that joins is **done for the round.** It does not activate again.

> **The tempo cost is the entire point.** Form up eight figures and you have burned
> eight activations in a single beat of alternation — and the enemy, who spent one,
> now takes seven in a row against a line that has already committed. Empty your
> side early against someone still holding theirs and you will be pushed off the
> table. **God speed.**
>
> That is the trade: one devastating coordinated blow, paid for with the initiative.
> It is a commitment at the *round* level, not the figure level, and it is the
> largest single decision in the game.

### You hit what you move into
A formed-up figure may only strike the enemies **it physically moves into.** Not
the one beside it, not the one its neighbour reached — the ones its own base makes
contact with.

The exception is a **Reach** packet, which strikes out to X″ but not while bases
touch (§8) — so a second rank contributes without being in the front.

> **This is what makes shape mechanical.** A column concentrates few bases on a
> narrow front and punches through. A line spreads contact wide and shallow. A
> wedge splits the difference and buys flank angles. Nobody had to write a
> column/line/wedge rule — the geometry *is* the rule.

### Movement distance — SIGNED (William, 2026-07-25)
The formation moves up to the **shortest Move among its members**, maintaining shape
as closely as practical.

A body travels at the pace of its slowest man. Put a Slow figure in the line and the
**whole line is slow** — so who you bring is a real cost, not just a body count. It
also gives the wounded, the armoured and the heavy a downside that no stat line had
to carry, and it makes leaving someone out of the formation a live decision.

---

# 12 · The round — alternation & the one pool  `[Agency]`

Combat's activation model:
```text
Side A activates one Figure → Side B activates one Figure → repeat until exhausted.
```
If one side runs out of eligible Figures, the other resolves its remainder one at
a time. Wild/uncontrolled figures resolve afterward per the owning procedure.
Alternation is **attention management** — a camera that directs focus to the
hottest fight. `→ G·alternation-is-not-initiative`

## One pool — SIGNED (William, 2026-07-27)
**Combat spends AP and nothing else.** There is no second Resource for someone
else's activation:

- **Every trigger is free.** Counters (§9), shield intercepts (§9b), reach strikes
  (§8) and an armed Overwatch (§9b) cost no Resource to resolve. They are gated by
  **Position, authoring and death** (Document A · IV), not by a budget.
- **A trigger fires once per occurrence of its condition**, and a movement is one
  occurrence however finely the clash slices it (§8, Document F).
- **AP refreshes at the start of the figure's own activation.**
- **An armed WAIT expires** when the figure next activates, at the same moment —
  which is the real reason activation order still carries weight.

> **Earlier drafts budgeted a `Reaction` pool** — `1 per figure · 2 for a Circle`,
> one spent per trigger. **Struck 2026-07-27** (Document E · `reaction-struck`).
> What used to cap a figure's answers is now its **front arc** (§8): it answers
> what it faces and concedes what it doesn't. A Circle, being faceless, answers
> everyone — which is what its two Reactions were approximating.

## Round procedure — SIGNED (William, 2026-07-25)
```text
START OF ROUND
  1. Every surviving figure is marked ELIGIBLE (unactivated).
  2. The starting side ALTERNATES from the previous round.
     (First round of the game: the scenario says, or roll off.)
  3. The starting side picks its first eligible figure.

THE ROUND
  4. Sides alternate single figure activations.
  5. On activation: refresh that figure's AP; expire its armed WAIT;
     mark it ACTIVATED.
  6. It spends AP on MOVE / ACTION / WAIT.
     — or a Sergeant calls FORM UP (§11), which activates every
       joiner at once. Those figures are spent for the round and
       the alternation continues from the other side.
  7. Triggers fired during anyone else's activation resolve as they
     occur, free, whether or not the reactor has activated yet.
  8. If one side runs out of eligible figures, the other resolves
     its remainder one at a time.

END OF ROUND
  9. The round ends when neither side has an eligible figure.
     Wild/uncontrolled figures resolve last, per the owning procedure.
```

> **Refresh is on activation, not on the round.** A figure that has already
> activated has spent its AP and its armed WAIT expired the moment it went, so it
> holds nothing but its written triggers until its turn comes round again. **Hit
> the ones who have already gone** — not because they cannot answer, but because
> they cannot answer with anything *better* than what their weapon already says.
> `→ G·alternation-is-not-initiative`
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
player:  MOVE · [weapon] "Spear Thrust" · GRADE 1/2/3 · Brace
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
