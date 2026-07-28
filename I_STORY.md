# CUS — THE STORY MODULE

### v0.6 · Document I · Combat's peer · drafted 2026-07-26

> **What this is.** The Kernel doing its second job: everything contested that
> isn't a blade. The parley, the bargain, the recruitment, the taunt, the court,
> the grudge, the oath. Combat (Document B) is the *reference* implementation;
> this is the first **peer**, and therefore the first live trial of Law 12.
> Everything here is a **Story Module fact** — retunable, never Kernel law.
>
> **Status — ⚠ PROPOSED THROUGHOUT.** Nothing here is authority until signed.
> The Register at the foot lists every ruling this document needs; a section's
> ⚠ comes off when its line is signed. Where this draft had to choose, it chose
> **visibly** and put the choice in the Register.
>
> **Citation rule.** Every mechanic names the Kernel primitive it reads or
> writes: `[Position]`, `[PACKET→Grade]`, `[Agency]`, `[State]`. If it can't
> cite one, it doesn't belong here (Law 14).
>
> **Translation.** Story renames two of the three verbs:
> `ACTION→Address · WAIT→Prepare`. **MOVE stays MOVE** (B's signed precedent) —
> *approach, withdraw, take the floor* are kinds of MOVE, not renames.
> *(Carries a one-word amendment to A·XIII: retire **Challenge** for
> **Address**. An offer, a comfort, a joke are ACTIONs too; "Challenge" narrows
> the verb to the duel. Register: `xiii-address`.)*
>
> **On "not."** Where the obvious reading is wrong you'll see `→ G·<slug>`; the
> arguments are drafted in the Appendix, ready to fold into **Document G**.

---

# 1 · What Story owns

```text
BONDS       the standing tie between two agents — loyalty · grudge · kinship ·
            debt · trust · rivalry · promises · oaths
STANDING    what an audience currently believes a figure to be
THE SCENE   contested Asks, resolved with dice
THE RECORD  what happened, and what it meant to the people it happened to
```

**Story interprets; it never rewrites the record.** What mechanically happened is
Combat's or the Aftermath's. What it *meant* — and what it changed between
people — is this module's.

---

# 2 · The Scene — when the dice come out `[Position]`

Talk is free. This module does not resolve conversation; it resolves **contested
Asks.**

```text
ASK         one party wants something it does not have
RESISTANCE  another party resists it
            ↓
SCENE       dice come out · the stakes are spoken · turns keep going around
```

- **Free talk is Presentation, never Procedure.** Two players haggling in
  character, a kid interviewing the blacksmith, table banter — none of it rolls,
  ever. A rule must justify the attention it costs; unresisted talk costs none.
  `→ G·talk-is-not-a-minigame`
- **The stakes are spoken before the first die.** What is asked, what is offered,
  what losing costs — out loud, the way a Form Up declares its strikes before
  contact (B·11). An undeclared stake cannot be won.
- **Scenes are short by design.** Two or three rounds decides a parley. A scene
  that runs long is one whose Position has stopped changing.

## No re-rolls — the standing-result law — ⚠ PROPOSED

**A failed Ask cannot be re-asked. It reopens only when Position changes** — new
evidence, new standing, new leverage, a new witness, a different room.

The refusal *stands*, exactly as a resolved Grade stands. What it does **not** do
is close the world. Change the Position, then ask again. **A failed Ask is a
quest, not a wall.** `→ G·no-rerolls-change-the-world`

---

# 3 · Formality is a dial, not a switch — ⚠ PROPOSED (William)

There is **no mode switch anywhere in CUS.** Nothing pauses, nothing reboots.
Formality changes what a turn *costs*, never who acts next.

```text
turns only                     the tavern — going around, who does what, no dice
turns + dice                   a negotiation prompts — stakes named, Composure at risk
turns + dice + measurement     steel out — inches matter now
```

A tavern is not unstructured; it is **the round already running with nothing
spent.** When a negotiation prompts mid-scene you are not entering a mode, you
are spending on this turn what you weren't spending before. And if it goes to
steel, **everyone else still gets their turns.**

`→ G·the-parley-was-already-the-game`

---

# 4 · Tools — Presence · Word · Hybrid `[Definition]` — ⚠ PROPOSED

A vibe-check vocabulary, the same shape as Combat's (Law 10):

```text
Presence · Word · Hybrid
```

- **Presence** — delivered in the room: the face, the voice, the standing body.
- **Word** — delivered carried: letters, heralds, rumour, the song sung about you
  in a tavern you have never entered.
- **Hybrid** — meaningfully both.

## `in_presence` — the standing constraint — ⚠ PROPOSED

The mirror of Combat's `not_in_contact` (B·5). Most **Presence** packets carry
`in_presence` — they cannot resolve against a target who cannot see and hear you.

**Word acts without presence and never draws a Retort** (§8). You cannot answer
what is said behind your back. That is exactly why Word is the coward's tool, and
the constraint prices it honestly: safe from the comeback, slow to arrive, blind
to the room. **Gossip is ranged.** `→ G·gossip-is-ranged`

---

# 5 · Composure — the number `[State]` — ⚠ PROPOSED

**Composure is a number, not a track** — the same shape as Wounds (B·7). How much
pressure a figure absorbs before the scene breaks it. **Standard is 2–3**; a knob.

```text
composure_remaining > 0  →  in the scene (no state; read the number)
composure_remaining = 0  →  YIELDED  or  MOVED         [State]
```

**Keep it small.** A figure that absorbs eight cutting remarks isn't composed,
it's a wall — and walls turn this into the attrition minigame nobody plays. Two
is dangerous. Three is stout. `→ G·composure-is-not-hit-points`

**Refresh** at scene end — a breath, a drink, a night (knob). What was conceded
does *not* refresh with it: the concession was written to the world, not the pool.

## Yielded — the scene lost
Ends the figure's part in the scene. The contested Ask resolves against it, the
spoken stakes land, it takes no further Address. It may MOVE; leaving is always
legal and the room watches it go. Clears at scene end. **What it conceded stands.**

## Moved — the mind changed — **Squares only**
**Real persuasion.** The figure's disposition genuinely changes — it believes, it
defects, it swears, it joins — *sincerely*, and it persists as a **Bond** (§10).
The Effect that lands the final Composure decides what Moved means, exactly as the
felling Effect decides Knocked Out or Dead (B·7); where the Effect is silent, the
target is won to the Ask.

## Creature Type in the parlour
Mirrors Nerve's gate (B·10, B·13): **Man** — the full module. **Beast** — can be
cowed (Pressure Asks only), never bargained with. **Spirit** — answers what its
nature allows, authored per spirit. **Construct** — does not attend; it takes
orders, not Asks.

---

# 6 · Player figures hold `[Definition]` — SIGNED (William, 2026-07-26)

> **Amended from "Circles hold."** The original law said *Circle* when it meant
> *a figure a player is running*. On the day it was drafted those were the same
> set, so nobody noticed. They are not the same set now.
>
> **One word was carrying two predicates. They are now named separately:**
>
> ```text
> RANK     Circle / Square — a Definition axis. Faceless, unbreakable. Exceptional.
> CONTROL  played by a person  /  run by the chair.
> ```
>
> Every sacred-figure law must say which one it turns on. `→ G·rank-is-not-control`

```text
A PLAYED figure can be YIELDED.   A PLAYED figure can never be MOVED.
An NPC Circle CAN be Moved. An enemy champion is persuadable.
```

The law rests on **CONTROL**, not Rank. It exists to protect **player
sovereignty**, and no rule ever decides what a player's figure believes or
chooses — Law 9 in the parlour.

Social force against a played figure binds **the world, never the will**: the
crowd believed it, the insult is public, the offer stands, the scene was lost and
its stakes with it. The player alone decides what their Champion *believes*.

**And the enemy champion across the table is fair game.** Talking a rival warlord
down is a legal, difficult, campaign-shaping thing to attempt — which is exactly
what the module is for.

- **Consequences, yes. Conversion, never.** A Yielded Circle really did lose. The
  staked thing is gone; the player narrates what conceding looks like, but the
  concession is real. Hero-sacredness protects the person, not the outcome.
- **Pressure stays loud.** Everything may shout, plead, tempt and lie at a
  Champion at full volume. The module's job is to make the pressure real and
  leave the choosing untouched. `→ G·moved-is-not-mind-control`

---

# 7 · Position in the parlour `[Position]` — ⚠ PROPOSED

Depth comes from Position first (A·II). **Before the first die, the table speaks
the Position facts that bear** — out loud, WYSIWYG:

```text
whose ground         the hall is his — the room answers to him
who is watching      the audience, and whose side it leans
who holds the floor  which voice the room currently grants
what is known        the letter on the table, the lie already caught
standing             what this audience currently believes each figure to be
```

- **Earshot is range.** On the board, physical truth answers first (Law 8):
  conversation ~12″, a shout carries the table, a whisper is base contact — knobs.
  Off the board, the situation *is* the board.
- **The audience is terrain.** Witnesses change what is legal (you do not threaten
  openly in court) and what a Grade means — a public miss costs more than a
  private one.
- **Home ground is armour, and the only armour.** There is **no social armour roll
  and no Poise stat.** Position loads the dice exactly as elevation and facing do
  in combat. `→ G·no-social-armour`
- **Hierarchy is Position — SIGNED-PENDING (William).** A king gets **ordinary
  Composure.** Kings lose their composure constantly; rank tricks us into thinking
  he isn't just a man. His protection is not in him — it is the herald who speaks
  first, the court that decides what's sayable, the guards, the protocol, the
  ground you stand on. **Hierarchy is armour made of other people** — and every
  piece of it is a figure you can also work on. `→ G·hierarchy-is-position`
- **Standing is a Position fact, not a meter.** "She is their captain." "He was
  caught lying an hour ago." Losing Standing means the fact changed. No stat.

> **The cost of this, accepted knowingly:** the obvious difficulty knob is gone,
> so weight moves onto **authored Position and Temperament**. A king at Composure
> 8 is a scene that plays itself; a king at Composure 2 in an unbuilt room ends in
> one line and feels cheap. The trade is a number for prep, and the prep lands on
> the DM chair — which is the strongest argument yet that scenario terrain and NPC
> Temperaments are what a first edition ships hard.

---

# 8 · PACKET resolution `[PACKET→Grade]`

A social PACKET is a PACKET (A·V): `dice · success_number · constraints · grades ·
effects` — referenced, never copied; Grades discrete per Model 2 (A·VI). The flow
drops Combat's armour step and gains an utterance:

```text
speak the attempt               (in character or in gist — §12)
→ declare the target / Ask      [Position: presence, earshot, witnesses]
→ load Position modifiers       (ground / audience / standing)
→ roll dice → count Successes → determine Grade
→ resolve Effects               (Composure, Standing, States, Information)  [State]
→ resolve Retort / aftermath
```

## Plain Words — standard equipment — ⚠ PROPOSED
**Every figure carries `plain_words`** — the social Fists (B·5). Not printed, not
bought, never lost.

```json
"plain_words": { "dice": 1, "success": 5, "grades": { "1": "1 Composure" },
                 "constraints": ["in_presence"], "provokes": true,
                 "trigger": { "on": "addressed_in_presence" } }
```

**The floor is never zero.** The tongue-tied brute can still say *no*, still jeer,
still beg. And because every figure always holds a packet with the retort trigger,
"address a figure to its face and it answers" holds without exception — and it costs
nothing, exactly as in Combat. (`→ G·support-units-are-not-defenceless` carries
whole.)

## The miss is an utterance — Grade 0 — ⚠ PROPOSED
A combat miss is physics: nothing happened. A social miss happened **out loud** —
the room heard you try. **Social packets may author a Grade 0 line**, and good ones
do: what the fumble sounds like, what it costs — usually Standing, before this
audience. `→ G·a-miss-is-an-utterance`

## Two illustrations *(illustrative, not content)*
```text
JEER — Presence · Dice 3 · Success 4+ · constraints: [in_presence]
  GRADE 0 — the room hears it fall flat; you lose Standing here
  GRADE 1 — 1 Composure
  GRADE 2 — 1 Composure + answer, or lose Standing before this audience
  GRADE 3 — Provoke: an Aggressive or Ravenous target takes 1 Morale (Nerve saves)
            [OWNED_PROCEDURE → Combat's Mind channel — §9, B·10]

FAIR OFFER — Presence · Dice 3 · Success 4+
             constraints: [in_presence, offer_on_table]
  GRADE 1 — 1 Composure
  GRADE 2 — 2 Composure
  GRADE 3 — 2 Composure; if this lands the last, the break is MOVED —
            the terms are taken sincerely
```

## The Retort `[PACKET→Written Trigger]` — ⚠ PROPOSED
Combat's Counter (B·9), translated whole — including the 2026-07-27 amendment.
Address a figure **in presence** and it **Retorts** — one social packet back — and
it **costs nothing**:

- A free target always gets its answer: the first voice on an open figure eats the
  comeback.
- **A Retort draws no Retort.**
- **Word never draws a Retort** — no presence, no trigger.
- **An Ask authored `provokes: false` draws no Retort** — the aside, the remark made
  past someone rather than to them, the question asked of the room. Mirrors B·5.
- **Simultaneous break — both break.** If your Address breaks the target and its
  Retort breaks you, both go. The dying line lands (B·9, unchanged).

### What caps it is attention — the mirror of facing — ⚠ PROPOSED
Combat's Square answers **the face** and concedes its flanks (B·8). Story's figure
answers **the voice it is engaged with**:

> **A figure Retorts the exchange it is in.** A second voice pressing while it is
> answering the first is speaking at its shoulder — **no Retort.** That is the
> conversational flank, and everyone has been on both ends of it: talk over a man
> while he is answering someone else and he cannot answer you too.
>
> A **Circle** answers everyone, from any side. The champion is never talked over.

This is where the badgered witness went. He no longer runs out of *wit* — he runs out
of **attention**, and a crowd working him from three sides is doing something real to
him rather than draining a number. Combat's amendment translated without loss, which
is the test Story exists to pass.

## Answer For — the intercept — ⚠ PROPOSED
The shield intercept (B·9b), unarmoured: **consume a social packet aimed at a
friendly in your presence — the question lands on you instead**, at no cost.
*"I'll answer that."* The advocate, the older sister, the sergeant stepping in
front of the recruit. The interceptor's own Composure eats the Grade; no Retort —
it wasn't the one addressed. **No trait required.** *(⚠ If play shows it too
strong, gate it behind an `advocate` trait — the shield precedent.)*

## The budget — there isn't one
```text
Agency (AP)  →  what you say on your turn
answering    →  free, gated by PRESENCE and ATTENTION
```
Mirrors Combat (B·12) after the 2026-07-27 amendment: **there is no second pool.**
A figure answers what is put to its face, as often as it is put there, and stops
answering when the room stops facing it. *(This section previously read
`Square → 1 Reaction · Circle → 2 Reactions`. Struck with the Resource,
E · `reaction-struck`.)*

---

# 9 · The bridges `[OWNED_PROCEDURE]`

## Nerve — no second morale system, ever — ⚠ PROPOSED
Social packets resolved **on the battlefield** reach morale through the door
Combat already built: a Grade Effect **deals Morale on Combat's Mind channel** as an
OWNED_PROCEDURE — Nerve saves it (B·10). Composure is a *scene*
resource; Nerve is *Combat's* procedure; this module writes neither a copy nor a
fork (Laws 1, 7). Demand surrender, jeer across the line, talk a rout onto shaken
men — all of it is social packets firing Combat's own machinery.

## Escalation — steel mid-parley — ⚠ PROPOSED
**The scene never restarts.** Drawing a blade is a MOVE or an ACTION taken by a
figure with Agency to spend, on the same table, in the same round, from the same
pools. Alternation continues, AP rides, Composure stays where it stands
and waits for the next scene. The conversation and the fight were never two games.

*(The reverse door is already open: earshot exists on a battlefield, so mid-combat
Asks are simply Presence packets with `in_presence` satisfied.)*

## Harm — when a scene leaves a mark — ⚠ PROPOSED
Composure refreshes; some scenes don't. Story supplies the **events** that cause
**MIND injuries** (H·7.6) — *he answered a call for help and it was a trap · one
of his own betrayed him · he did a thing that cannot be undone.* A scene that
produces one of those triggers hands it to the Aftermath; the lifecycle is
Harm's, the event is Story's.

**MIND heals with relationships** (H·7.8) — which is Bonds, which is this module.
A figure with no Bonds does not recover from what he saw.

---

# 10 · Bonds `[State]` — ⚠ PROPOSED

The standing tie between two agents, and this module's core persistent object.

```text
BOND   loyalty · grudge · kinship · debt · trust · rivalry · oath
```

- A **Moved** figure's changed disposition **is a Bond** (§5). That is the
  mechanical hook under "retinue come and go": the spearman deciding whether he
  still works for you **is a scene**, and now it has rules and spoken stakes
  instead of a coin flip.
- A **vow** is a **WAIT** — spent now, armed against a later trigger.
- A **grudge** is a **Written Trigger** (A·XIV) — a clause the Figure simply
  carries, firing when its condition is met, armed by nobody. Structurally the
  same object as a Counter, which is why trauma and hatred needed no new
  machinery (see H·7.7 — every MIND scar that fires on a condition is one).
- **Directed or mutual?** ⚠ OPEN. Someone may hold a bond to a figure who cannot
  return it. That asymmetry matters and is not yet ruled.

Bonds persist between events. **Where they are stored is Persistence's problem,
not Story's** (A·XIX — reserved for the Kernel).

---

# 11 · Temperament under pressure `[Temperament]` — ⚠ PROPOSED

The five words are Kernel law (A·VII); Story owns what they **do**. The first
column also serves the figure **approached alone** — the hireling at the tavern,
the sentry offered a purse — which is this table's real customer.

| Temperament | Under pressure (or approached alone) — it… | At Composure 0 — it… |
|---|---|---|
| **Cowardly** | agrees to anything, means none of it | **Yields** instantly; complies only while watched |
| **Resolute** | stonewalls — pressure alone never lands | **Yields** the scene, never the position; only *terms* can Move it |
| **Aggressive** | answers argument with dare; escalates | may take **escalation** instead of Yielding — reaches for other tools (§9) |
| **Protective** | concedes whatever shields its own | **Moved** by any offer that genuinely protects its people |
| **Ravenous** | wants, openly | buyable — **Moved** by the thing itself |

---

# 12 · Turns — continuous, everywhere — ⚠ PROPOSED (William)

**Turns keep going around. On your turn you do whatever your figure is doing —
Strike, Address, or nothing.** One activation model at every formality level.

```text
START OF SCENE   every participant is ELIGIBLE. Declare the going-around order
                 (seat order, or the party pressing the first Ask leads).
ON ACTIVATION    refresh AP; expire the armed Prepare; spend on
                 MOVE / Address / Prepare; mark ACTIVATED.
THE ROUND ENDS   when no figure is eligible.
```

Retorts are **triggers** and never move the floor: an interjection is not a turn.

At two sides this **is** Combat's alternation (B·12) — which is why it needed no
invention. A council or a market has no sides, so the only addition is a stated
going-around order at scene start.

> **Struck: *the floor follows the Ask*.** An earlier draft proposed a bespoke
> multi-party model where the floor passed to whoever was addressed, with fallback
> clauses for already-activated figures and party rotation. William replaced it
> with plain continuous turns: **one model everywhere, zero new rules to teach,
> and councils fall out for free.** The razor picks the second — the rare case
> where simpler also covers more.

---

# 13 · Presentation `[Presentation]`

**Speak, then roll.** The player says the attempt — in character or in gist — and
the dice say how it *lands*. The packet never replaces the roleplay; it resolves
it. For the shy and the young, the packet list is a menu of things one could say.
For the loud, it is the honest referee of whether the speech worked on anyone
other than its author.

```text
player:  "Lay down your spears and walk — nobody follows you."  · GRADE 2
system:  ACTION packet_id:demand_surrender · target · Grade · Effects
```

---

# 14 · Scope — no costs

**Social PACKETs are not point-costed.** The budget economy belongs to Skirmish
and Downtime. Story's currency is Position and consequence — what you staked, what
the room now believes, who you became to these people — and none of that has a
price in points.

---

# 15 · The DM seat  🔒 **reserved**

William expects to hold the voice, and wants an AI in the chair eventually.
Deliberately left unwritten here.

**On the record: `F_AI_DIRECTOR` was killed because it was sloppy and unwanted — a
brainstorm remnant that got accidentally ratified. It was never a ruling against
AI at the table.** That is a *process* failure, not a design one, and the fix is
already in place: the SIGNED / ⚠ PROPOSED / ⚠ OPEN convention, plus the same-day
register rule (E · Process). `→ G·the-director-was-a-process-failure`

Four charter laws, ⚠ PROPOSED:

```text
trigger-discipline → dice only on a contested Ask. An AI's first temptation is
                     calling for rolls; restraint is the skill being asked for
hands-off          → Law 9 + circles-hold at full strength. Pressure at maximum
                     volume, never the player's line, never the Champion's will
the-table-rolls    → the AI narrates and adjudicates; dice stay physical, in the
                     players' hands. An invisible roll is a negotiable roll
caravan-save       → campaign state persists somewhere real
```

---

# 16 · What this module owes the Kernel

Every section writes **Position**, resolves a **PACKET** into a **Grade**, spends
**Agency**, changes **State**, or reads a Definition axis. **No
fifth primitive was required** — the audience is Position, Composure is a number
under State, oaths and loyalties are State on relationships, Standing is a spoken
Position fact, Information is the Resource A·IV already names. Morale is not
forked (§9). Turns are Combat's own model (§12).

Where this document chose, it chose visibly. The Register is the pen.

---

# Register — ⚠ PROPOSED, for signature

```text
scene-trigger        → dice only on a contested Ask; free talk is Presentation
no-rerolls           → a failed Ask reopens only when Position changes
formality-dial       → turns only / +dice / +measurement. No mode switch exists
continuous-turns     → turns run at every formality level; one activation model
position-substrate   → Position may be measured or spoken; spoken facts BEFORE dice
composure            → a NUMBER (knob, standard 2–3); refreshes at scene end
the-two-states       → at 0: YIELDED (scene lost) or MOVED (persuaded, persists)
circles-hold         → a Circle can be Yielded, never Moved
creature-type-parlor → Man full · Beast cowed · Spirit authored · Construct absent
tool-vocabulary      → Presence · Word · Hybrid
in-presence          → Word acts without presence and never draws a Retort
audience             → witnesses are Position; no Poise stat, no armour roll
hierarchy-is-position→ rank confers no Composure; a king's difficulty is his hall
standing             → a Position fact, not a meter
plain-words          → the universal packet; the floor is never zero
the-miss             → social packets author Grade 0 — you said it out loud
retort               → free · no Retort on a Retort · both can break · `provokes`
retort-attention     → a figure answers the exchange it is IN; a second voice at its
                       shoulder gets no Retort. The mirror of facing (B·8)
answer-for           → intercept for a friendly in presence · free · no trait required
no-budget            → there is no second pool; answering is gated by presence and
                       attention (mirrors the 2026-07-27 strike of Reaction)
temperament-social   → the five under-pressure / at-break behaviours (§11)
nerve-bridge         → battlefield social invokes Combat's Nerve; no fork, ever
escalation           → steel mid-parley continues the same round and pools
harm-bridge          → Story supplies the events behind MIND injuries (H·7.6)
bonds                → Moved states, vows, grudges are Bonds; storage is the Kernel's
bond-direction       → ⚠ OPEN: directed or mutual?
free-play-is-free    → board optional for talk; required once stakes have geometry
shared-clock         → a scene and a fight on one board share one clock
no-costs             → social PACKETs are not point-costed
xiii-address         → amend A·XIII example row: Challenge → Address
dm-charter           → the four charter laws (§15)
floor-follows-ask    → ✂ STRUCK — superseded by continuous-turns
```

Sign, strike, or send back. Each signed line folds into **Document E**, its ⚠ comes
off the section it governs, and its stub folds into **Document G**.

---

# Appendix · G stubs

**G·talk-is-not-a-minigame** — The obvious build resolves conversation.
Conversation does not need resolving; contested stakes do. Every social subsystem
that died at a real table died by swallowing talk — the moment "I chat with the
innkeeper" costs a roll, players route around the whole chapter. The trigger is
the crispest rule in the module because it decides whether the module gets used.

**G·no-rerolls-change-the-world** — Re-rolls teach players to grind the die instead
of the situation, and they rot determinism-as-trust: if a *no* becomes a *yes* by
asking again, the *no* was never a result. But a permanent *no* makes failure a
wall, and walls end play. The law threads it: the result stands, the world stays
open. Failure becomes a quest generator. *(Prior art, named honestly: Disco
Elysium's white check — the best social rule ever shipped, and one sentence long.)*

**G·moved-is-not-mind-control** — Two failure modes killed social mechanics
everywhere they were tried. Either the dice seize a player's character — mutiny at
the table, house-ruled out by session two — or the player is immune and social
force is theatre. The Circle/Square split already solved this shape for morale;
the module inherits the answer instead of inventing one. Squares can be genuinely
Moved, because retinue having wills of their own is the campaign's premise.
Circles suffer every consequence and no conversion.

**G·gossip-is-ranged** — The retort trigger is presence: you answer what is said
to your face. Slander in another room reaches you as a changed Position fact, not
an addressable utterance — there is nothing standing in front of you to answer.
Not a balance patch; the actual physics of reputation. And it leaves a carrier:
the letter exists, the herald can be caught.

**G·composure-is-not-hit-points** — The temptation is to make Composure big so
scenes feel substantial. Backwards: a big pool makes a scene an attrition grind,
and the grind is the debate minigame nobody plays. Two-to-three means a parley
turns on two good lines and one bad one, which is how real arguments go.

**G·no-social-armour** — A Poise save was considered and cut. Combat's armour
exists because steel is a fact you wear regardless of where you stand. Social
resistance almost never is — it is the hall, the crowd, the rank, the caught lie:
all Position. Give figures a Poise stat and every scene becomes stat-versus-stat
with the room as wallpaper; make Position load the dice and the room *is* the game.

**G·hierarchy-is-position** — A king gets ordinary Composure because kings lose
their composure constantly; rank tricks us into thinking he isn't just a man. His
protection is real but it is *outside him* — the herald, the court, the protocol,
the guards, the ground. **Hierarchy is armour made of other people**, and every
piece of it is a figure you can also work on. The cost is honest: no difficulty
knob, so the weight lands on authored Position and Temperament, and therefore on
the DM's prep.

**G·a-miss-is-an-utterance** — In combat a miss resolves to silence because physics
has no memory of intent. A room does. The failed threat was heard; the clumsy
bribe is now a fact about you. Authoring Grade 0 costs a line of text and buys the
thing social scenes are actually about — consequence for opening your mouth.

**G·the-parley-was-already-the-game** — Every RPG with a social system has a seam:
*"roll initiative"* — the moment talk fails and a different game boots up. The seam
teaches players that talking was the lobby. CUS refuses it on principle: one table,
one round, one economy — so the blade drawn mid-sentence is just the next AP spent,
and the sentence still hangs there when the fight ends. If this module ever needs a
scene-restart, that is a Law 12 alarm, not a feature request.

**G·the-director-was-a-process-failure** — `F_AI_DIRECTOR` is the only document
CUS has ever deleted outright, and the reason is worth keeping. It was not a bad
idea rejected on its merits; it was a **brainstorm that got accidentally ratified**
— it entered the authority set without anyone signing it, then accumulated
mechanics (Prone, Mindless-as-a-Temperament, a SLOT budget) that existed in no
other document. The design lesson is small. The process lesson is the whole point,
and the fix is structural: SIGNED / ⚠ PROPOSED / ⚠ OPEN on every line, and a
verbal ruling written into the register **the same day** (E · Process). Nothing
gets to be authority by sitting still.
