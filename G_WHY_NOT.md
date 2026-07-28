# CUS — WHY NOT

### v0.6 · the rationale register · 2026-07-25

> **What this is.** Every place CUS says *"X is **not** Y"*, this is where the
> argument lives. A–C state the rule; this document explains why the obvious
> reading was wrong. Read it once. You should never need it twice.
>
> **Why it exists.** The rules documents had accumulated ~100 defensive
> negations — sentences refuting positions nobody in the room had taken. They
> made the Constitution read like an argument instead of a set of laws. The
> rules stayed; the arguing moved here.
>
> **The rule for authors.** A negation that **is** the rule stays in A–C
> (*"Circles never break"* is a rule). A negation that **defends** the rule comes
> here (*"Tempo is not Move distance, initiative, attack speed, range, AP count,
> or damage"* is a defence). If you catch yourself writing "not Y," ask whether
> a reader who had never heard of Y would need the sentence. If no, it belongs
> in this file.
>
> **How it is cited.** A–C carry a token, never a paragraph:
> `→ G·tempo-is-not-speed`

**The other two homes.** Not every "not Y" belongs here:

```text
Y is old vocabulary        → Document D (Migration Map)  — where your old word went
Y was proposed and refused → Document E (Decision Register) — the signed ruling
Y is what a reader assumes → THIS DOCUMENT — the trap and why it's a trap
```

---

# The four axes

### tempo-is-not-speed
**Tempting.** Tempo is how fast the model moves. Or how early it acts. Or how
many attacks it gets.

**Why not.** All three are already owned elsewhere. Move distance is **Position**
(written by MOVE). Acting order is **alternation** (B·12). Attack count is
**Agency**. If Tempo were any of them it would be a second authoritative copy of
another mechanic's information — Law 1.

**Instead.** Tempo is *the time it takes to apply Force relative to its peers.*
An artillery piece out-ranges everything on the table and is still **Slow**,
because the interval between opportunity and delivered Force is long. A duellist
with a knife is **Fast** at three inches and irrelevant at twelve.

**And note.** Tempo is **read by humans, never by the resolver.** It is a vibe
check that helps you pick units and eyeball a matchup. No procedure consumes it.
That is deliberate — see `→ G·not-every-axis-needs-teeth`.

### not-every-axis-needs-teeth
**Tempting.** Tempo has no procedure, so by Law 14 it is illegal and must either
get a mechanic or be cut.

**Why not.** Law 14 governs **mechanics** — things that resolve. Tempo resolves
nothing and never claims to. It is a reading aid at the Presentation layer
wearing an axis's clothes, and it earns its place the same way a good icon does:
it makes a card legible at a glance.

**Instead.** Treat Tempo as the one axis on the reading side of the line. Role,
Tool and Temperament feed procedures; Tempo feeds intuition. If it ever starts
getting rolled, that is a bug.

**The temptation to resist:** deriving Tempo from Move and AP. That would turn a
classification into a measured statistic, which is exactly what Law 10 forbids,
and it would collapse Tempo into Move — the thing this entry exists to prevent.
If you want it policed, lint it (flag a *Fast* unit whose stat line reads slow);
do not compute it.

### role-is-not-a-job-list
**Tempting.** Pressure/Anchor/Utility should cover every effect a figure can
produce, so a unit that heals *and* shoves needs two Roles.

**Why not.** Role names an agent's **primary relationship with Force**, not the
union of its packets. Every interesting figure does more than one thing; if Role
had to enumerate them it would stop being a classification and become an index.

**Instead.** One Role. Express the rest through Tool, Temperament, PACKETs and
Position.

### tool-does-not-set-purpose
**Tempting.** Melee units are the aggressive ones; Ranged units are support.

**Why not.** Tool is the **channel** Force travels down, not what it is for. A
spear wall is Melee and pure **Anchor**. A sniper is Ranged and pure **Pressure**.
Collapsing the two would make half the interesting builds unspellable.

**Instead.** Read `Role × Tool` as a grid, not a synonym. That grid is where
Archetypes come from → `G·archetype-is-not-a-primitive`.

### temperament-is-preference-not-capability
**Tempting.** A Cowardly unit is bad at fighting. An Aggressive one hits harder.

**Why not.** Temperament describes **what a figure prefers to do** when several
legal applications of Force are open — not what it is able to do. A Cowardly
veteran with a heavy crossbow is lethal; it just refuses to be the one standing
in front.

**Instead.** Read Temperament as the AI fallback and the Rout behaviour (B·10).
It never modifies a die.

---

# The executable objects

### packet-has-no-alignment
**Tempting.** PACKETs should carry a harmful/beneficial flag so the engine knows
whether to allow friendly targeting.

**Why not.** Alignment is not a property of the effect — it is a property of the
**pairing**. A Shove is a gift when it pulls a mate out of a lance's lane and an
attack when it breaks his Brace. The same heal is an insult to an undead. Tagging
the packet freezes a judgment that only target-plus-context can make, and every
game that does it ends up writing exceptions to its own tag.

**Instead.** Target + context decide. No tag. *(Signed ruling: E.)*

### not-every-packet-rolls-dice
**Tempting.** PACKET is the universal object, so it should have every field
anything might need — dice, range, area, duration, cost, save, the lot.

**Why not.** A universal object that carries every possible field is not a
universal object, it is a union of every module's private schema wearing a shared
name. Most of it would be null on most packets, and the nulls would breed
validation rules.

**Instead.** The **owning module** decides which fields its packets require. A
command PACKET with no dice and no range is a perfectly good PACKET.

### grade-is-not-a-tier
**Tempting.** Grades are the old Ladder with a new name, so Grade 3 should
include everything Grades 1 and 2 gave you.

**Why not.** That is Model 1, and it was rejected. Accumulation means every roll
resolves *n* effects and the reader has to hold a running total — the exact
cognitive tax the rebuild was meant to remove. It also makes high Grades scale
super-linearly, so packets get harder to price the better they get.

**Instead.** **Model 2 — Discrete.** Read the one line you reached; resolve only
what is written on it. An effect that should carry up gets **printed on every
line that should have it.** Reads top-to-bottom as independent outcomes.

**The trap this creates.** Because higher Grades do not inherit, a designer can
accidentally write a Grade 3 that is *worse* than Grade 2. That is an authoring
bug, not a rules question — lint for it.

### traits-are-not-base-properties
**Tempting.** `Large` and `Mounted` are always true of a figure, and Traits are
always-true properties, so they should be traits.

**Why not.** Both are already stored on the **base**, where you read them off the
footprint. Putting them in `traits` too means two authoritative copies of the
same fact, which is Law 1 — and they will drift the first time someone rebases a
model.

**Instead.** `base.size_class` and `base.mounted` are base facts.
`traits` holds behaviour: `unstoppable`, `reach`, `flying`, `shield`. A
"monstrous" figure is a **Large base carrying `unstoppable`** — never a trait
called *Large*.

---

# Time, reactions & commitment

### wait-is-not-a-written-trigger
**Tempting.** Everything that resolves on someone else's turn is a WAIT, so a
Counter must be an automatic WAIT that nobody had to arm.

**Why not.** That definition eats itself. WAIT means *a player spent AP now to
arm a chosen PACKET*. If Counters are WAITs, then either every figure is
permanently armed for free — in which case arming means nothing — or WAIT has a
silent second mode. Both wreck the verb.

**Instead.** Two distinct things, neither of them budgeted:

```text
WAIT             player spends AP now to arm a PACKET OF HIS CHOOSING
Written Trigger  a PACKET carries its own trigger clause; no AP, no arming
                 ↓
neither costs anything to resolve. The difference is the AP and the CHOICE.
```

**Amended 2026-07-27.** These two used to be unified by a shared cost — both spent a
Reaction. With Reaction struck, what distinguishes them is what always actually
distinguished them: **a WAIT is a decision a player paid for, a Written Trigger is a
clause the designer wrote.** The AP buys you a *better* answer than the one your
weapon already carries. That is a cleaner account than the pool ever gave, because
the pool made a Counter and an Overwatch look like the same purchase.

### three-verbs-is-not-three-invocations
**Tempting.** The Kernel has exactly three verbs, so every PACKET resolution must
begin with MOVE, ACTION or WAIT. A Counter has no verb, therefore either it's
secretly a WAIT or we need a fourth verb.

**Why not.** Both answers are wrong. Calling it a WAIT means arming is meaningless
(see `G·wait-is-not-a-written-trigger`). Adding a fourth verb hands the player a
choice they never make — nobody *decides* to Counter; the clause fires.

**Instead.** Separate **verb** from **invocation**. The player's menu stays at
three; the engine gets an honest fifth column:

```text
INVOCATION = MOVE | ACTION | WAIT | WRITTEN_TRIGGER | OWNED_PROCEDURE
```

Impact, Counter, Shield Intercept, a fall, Nerve — all reach the resolver through
the last two. Three verbs, five invocations, no lying.

### support-units-are-not-defenceless
**Tempting.** If a Counter lives on the weapon PACKET, a figure whose only packets
are HEAL, COMMAND or BLESSING has no counter clause — so wizards and healers simply
cannot fight back. Elegant! Ship it.

**Why not.** It was elegant, and it was also a figure standing in a melee with no
legal response, forever. That is not a vulnerability, it is a hole in the rules
wearing a vulnerability's coat. It also puts an asterisk on the one rule that should
never carry one: *strike a figure in contact and it answers.*

**Instead.** **Fists are standard equipment** — every figure carries a weak melee
packet with a counter trigger. The shape of the finding survives (a caster in melee
is in serious trouble) without the degenerate case (a caster in melee is furniture).
The floor is never zero; it is just very low.

**And it buys something.** A caster out of mana isn't finished, he's *downgraded* —
mana-out becomes a state with a path through it rather than a dead end. You talk
with your fists.

### morale-is-not-attrition
**Tempting.** The morale track only tests on shock and only Rally reliably walks a
figure back up, so a Shaken unit can never recover on its own. That's a missing
recovery rule.

**Why not.** It's a ratchet on purpose. If units drifted back to Steady on their
own, breaking an enemy would be a temporary inconvenience and the only reliable way
to remove a figure would be to kill it — which is attrition, which is the game CUS
is deliberately not.

**Instead.** **Pressure beats attrition.** A broken enemy costs you nothing further;
a dead one cost you every wound you had to land. The leader is the recovery valve,
which is what makes decapitation a *strategy* rather than a stat-check — and gives
the Protective temperament something real to protect.

### there-is-no-redemption-rule
**Tempting.** `hollow` (H · 7.7b) is a one-way door with no written exit. That
looks like an oversight — so write a Redemption procedure: a cost, a number of
periods, a check, and the man comes back.

**Why not.** The moment there is a procedure, there is a *checklist*, and the most
important thing one person can do for another becomes a line item you tick on the
way to a stat correction. Someone would work out the cheapest way to un-hollow a
veteran, and it would stop meaning anything at all.

**Instead.** Write no procedure. `hollow` is a description of what a man has lost,
not a puzzle with a printed solution.

**No "Redemption" heading, no procedure, no table entry.** This is the one place in
CUS where the correct rules text is an absence — and if a group works something out
at their own table, what they worked out is theirs.

### form-up-is-not-free
**Tempting.** Form Up lets a whole squad move and fight for 1 AP each. That has to be
strictly better than activating normally, so everyone will do it every round.

**Why not.** It costs the thing the AP total doesn't show: **the initiative.** Every
joiner is marked activated, so forming up eight figures burns eight activations in a
single beat of alternation — and the opponent, having spent one, takes the next seven
in a row against a line that has already committed and declared.

**Instead.** Read Form Up as a **round-level** commitment, not a figure-level
discount. One coordinated blow, paid for with the tempo to answer what comes back.
Empty your side early against someone still holding theirs and you get pushed off the
table.

### rank-is-not-control
**Tempting.** "Circles hold" and "Circles never test Nerve" are the same law
wearing two coats — heroes are special, so heroes are protected. Write them once
and be done.

**Why not.** They rest on **different predicates**, and the word *Circle* was
quietly carrying both:

```text
RANK     Circle / Square — a Definition axis. Faceless, unbreakable. Exceptional.
CONTROL  played by a person  /  run by the chair.
```

On the day both laws were drafted, every Circle on the table was also a player's
figure, so the two sets were identical and the ambiguity cost nothing. The moment
an enemy champion exists they come apart, and the rules give two different answers
depending on which meaning you happened to read.

**Instead.** Every sacred-figure law names its basis:

```text
circles-hold       → CONTROL.  A PLAYED figure can never be Moved.
                               An NPC Circle can. Enemy champions are persuadable.
never-tests-Nerve  → RANK.     Circles are exceptional. Holds for enemies too.
```

**The general lesson is the drafting one:** never let one term carry two
predicates. It reads fine for exactly as long as the two sets coincide, and then
it fails silently — mid-session, with the answer depending on who is reading.

### a-break-trigger-is-a-hook
**Tempting.** Enemy champions need a morale rule, so give them a special Nerve
test — a harder one, or one that only fires below half Wounds.

**Why not.** A champion who breaks because the dice said so is **arbitrary**.
Nobody at the table learns anything, nobody can plan around it, and the most
memorable figure in the scenario is decided by a number nobody chose.

**Instead.** A Circle breaks by a **prewritten trigger** — a Written Trigger
(A·XIV) authored onto that figure in advance, firing on its own condition.
**No trigger written means he fights to the end**, which is the right default.

A champion who breaks **when his brother falls** is a story, and players can work
out what breaks a man and go do it. Enemy Circles stop being damage sponges and
become puzzles.

**And notice what the object is.** A written condition, authored ahead of time,
firing unprompted with nobody's thumb on it — that is *exactly* a campaign hook.
An enemy's break condition and a scenario trigger are the same thing wearing
different hats, which means **one authoring format covers both**, and a hook
pipeline is already a break-trigger pipeline.

### counter-is-not-an-attack
**Tempting.** A Counter is an attack, so it should draw a Counter of its own.

**Why not.** It loops. Two figures with counter clauses would trade blows until
one died, on a single activation, with no player decision anywhere in the chain.

**Instead.** A Counter is a **response**, not a hostile ACTION. It does not draw
one back. *(Signed: E · counter-loop.)*

### a-pool-is-not-a-position
**Tempting.** Answering on someone else's turn is powerful, so meter it: give every
figure a Reaction pool, charge one per trigger, and the pool caps how often he can
be overwhelmed. *(CUS did exactly this from 2026-07-25 to 2026-07-27.)*

**Why not.** **Position had already answered that question.** B·8/B·9 deny a Counter
on an engaged Square's unfaced flank or rear — that *is* the anti-overwhelm rule, and
it is geometric. The pool was a second, numerical answer to a settled question: two
owners for one job, which is **Law 1**. It also ran against the Kernel's own thesis
(A·II): *depth comes first from Position — geometry, timing, facing — not from stacks
of numerical modifiers.*

The tell was in the Champion. A Circle had **2 Reactions** because a hero should
answer more attackers — but a Circle is *faceless*, so it already answers from every
angle. The number was restating the geometry, badly.

**Instead.** Out-of-turn response is **free**, and three things limit it:

```text
POSITION   contact, facing, range, presence — the geometry has to permit it
AUTHORING  the clause has to exist, and the striking packet has to provoke it
DEATH      a corpse answers once, on the way down
```

**What replaces the cap is the front arc.** Surround a spearman and he does not run
out of swings — he runs out of *directions*. So the answer to a shield wall stops
being "spend it down with chaff" and becomes "get around it," which is the answer the
Kernel keeps wanting to give.

**What it cost, honestly.** Chaff sequencing died — you cannot burn an enemy's
answers with bodies before landing the real blow, because there is nothing to burn.
That was a real tactic and it is gone. It was traded for envelopment, deliberately
(E · `reaction-struck`).

**And the anti-milking job** — the thing a pool quietly does well — passed to
**once per occurrence**: a trigger fires once per occurrence of its condition, and a
movement is one occurrence however finely you slice it (A·III, F).

Note what did **not** change: committing still forecloses. Facing one enemy concedes
the other arcs, exactly as spending your one answer used to. The design's thesis is
intact — it just runs on geometry now. `→ G·the-commitment-economy`

### brace-is-not-an-ability
**Tempting.** Brace is powerful, so it should be a skill some units have and
others don't, printed on a card.

**Why not.** Then a shield wall becomes a keyword you either bought or didn't,
and the wall stops being about *where you are standing*. The whole point is that
formation is emergent geometry.

**Instead.** **Any Square may Brace.** It is universal and never printed. What
varies is whether bracing is a good idea where you are standing.

### the-commitment-economy
**Tempting.** These are six unrelated rules: facing, the 3″ threshold,
interruption, Brace, Shield, discrete Grades, Disengage.

**Why not.** They are one idea found six times. Every one of them says:
**you get one commitment, and committing forecloses something.** Face one enemy and
concede the other three arcs. One clean run, or the charge fumbles on the chaff.
Lock your facing, lose the ability to turn. Read one Grade line, lose the others.

*(This list used to open with **Reaction** — one answer per round, then you are mute.
Struck 2026-07-27, and the thesis survived it unharmed, which is a decent sign the
thesis was never resting on the pool. `→ G·a-pool-is-not-a-position`)*

**Instead.** Treat this as the design's thesis and use it as a test. *Does this
proposal create a commitment with a real foreclosure — or is it just a modifier?*
If it is just a modifier, it probably does not belong in CUS.

### overwatch-is-not-free
**Tempting.** The Reaction pool is struck and the Counter is now free and
repeatable, so Overwatch should be free too — symmetry.

**Why not.** The Counter is free because two things already cap it: **reach is
short** and its **facing arc is one a flanker can leave.** Get around the shield and
the Counter never fires. **Neither cap exists down a firing lane.** A ranged facing
*cone* is long and covers a *volume* with no flank outside it — there is no "get off
his face." A free, repeatable overwatch would make lanes **absolute** and screens
**pointless**, which is the opposite of the game (A·II: depth from Position, not from
a wall of denial).

**Instead.** Overwatch is **priced (1 AP) and exhausts (one shot).** That is what
makes a screen work — cheap bodies eat the single shot and the anchor crosses behind
them. Same principle as the Counter (**Position caps out-of-turn response**), two
geometries, two prices: the short melee arc is free and repeats; the long lane is
paid and spent. The **shot ladder** then prices even that one shot by prior movement,
so a gun that paid for its ground in advance threatens more than one that just
arrived. `→ G·a-pool-is-not-a-position`

---

# Space & bodies

### push-is-not-damage
**Tempting.** Getting bulldozed by a warhorse should hurt, so the Push ought to
deal Wounds.

**Why not.** Then displacement carries two meanings and you can never tune one
without moving the other. It also duplicates what the Impact's PACKET already
does.

**Instead.** **The Push writes Position. Full stop.** Any Wound comes from the
**PACKET** the Impact resolves. The single exception is the wall-crush — nowhere
to go, so the blocked shove feeds the hit.

### shove-is-not-push
**Tempting.** They both move a model away from you, so they are the same rule.

**Why not.** They have different owners and different jobs. **Push** is the charge
plow — a movement geometry (`Push → Indent → Crush`) resolved as a body travels.
**Shove** is a weapon Grade **Effect** — a discrete displacement, X″ away ending
within Y″, that breaks a Brace.

**Instead.** Keep the words apart. "Push" is also free for ordinary English
because of this split; that was the point of the rename.

### mounted-is-not-a-size-class
**Tempting.** Cavalry is obviously its own base class, like Small or Large.

**Why not.** Because mounted models come in every size, and a Cavalry class would
force a second parallel size system — plus a heavy/light split, plus rules for
where the two systems interact.

**Instead.** **Mounted is geometry**: an elongated base of whatever size class.
Narrow frontage penetrates deeply, wide frontage bulldozes broadly, and a mounted
figure plows as one class larger. Cavalry doctrine emerges from
`Role · Tempo · Tool · Temperament · PACKETs · geometry` — never from a class.

### charge-is-not-an-action
**Tempting.** Charging is a thing you declare and spend AP on, like in every
other wargame.

**Why not.** It collided with movement. A declared charge needs its own range,
its own legality check, its own failure case — a second movement system bolted
beside MOVE, doing the same job with different words.

**Instead.** Charge is the **name for a Sprint that qualified**: 3″ of
uninterrupted straight run-up into contact. You never declare it; you either
earned the lane or you didn't. That is why denying room is the strongest
defensive act in the game.

### reach-is-not-a-role
**Tempting.** Reach changes how a figure fights so fundamentally it should be a
Role.

**Why not.** Role is a relationship with Force; Reach is a delivery geometry. A
Reach figure can be Pressure (a pike advancing) or Anchor (a spear hedge holding
a gap) — so Reach cannot *be* the relationship.

**Instead.** Reach is a **trait** and/or a PACKET property. *(Retired as a Role:
Document D.)*

### wounds-are-not-a-track
**Tempting.** Health should be a named state track — `Fine → Hurt → Knocked Out
→ Dead` — because states read nicely at the table.

**Why not.** *Fine* and *Hurt* were never states. They were prose for "has wounds
left" and "has fewer wounds left" — a second copy of the number, which is Law 1.
Worse, a four-state track gives **every figure in the game the same lifespan**,
so a rat and a troll die at the same rate.

**Instead.** **Wounds is a number** — 1 or 2 standard, a knob you twist per
figure. **Knocked Out** and **Dead** survive as the two genuine States, entered at
`wounds_remaining = 0`, because those change what a figure *can do* rather than
how hurt it is.

### no-lane-exempt-archetype
**Tempting.** An assassin is elite and slippery, so it should **skip** the killing
lane — teleport in, deploy from reserve behind the line, or make one outsized move
that crosses before anyone can shoot.

**Why not.** The lane is the game. Rangers threaten ground, screens absorb it, the
anchor pays to cross — that whole ecology only exists because **crossing a lane
costs something.** An archetype that skips the lane is exempt from the one game every
other figure is playing, and it collapses the rock-paper-scissors (rangers → mobile
armoured assassins → overwatched wizard) down to "the guy who ignores the rules
wins."

**Instead.** An assassin must **tank the lane, not skip it.** The correct elite
answer is **armour that survives the crossing** — it still pays, it just pays in
durability instead of bodies. Slipperiness that removes the payment entirely is bad
design wearing a cool coat. `→ G·the-commitment-economy`

---

# Organization & scale

### banner-is-not-a-command-state
**Tempting.** A Banner is an Order, or a Mission, or a command aura, or the
literal flag-bearer model.

**Why not.** Every one of those is a *thing that happens*; a Banner is a *thing
that persists*. Conflating them means your warband stops existing when nobody is
issuing orders.

**Instead.** A Banner is the **warband** — a persistent tactical group of
`Champion + Fireteams + loose specialists`. Missions are issued *to* it. The
flag, if there is one, is a model inside it.

### archetype-is-not-a-primitive
**Tempting.** Skirmisher, Tank, Sniper and Support are the real Roles — they're
what players actually say.

**Why not.** They are **combinations**, and treating a combination as a primitive
means the primitives underneath it can never be recombined. You end up needing a
new "Role" every time someone builds a fast shooty anchor.

**Instead.** `Role + Tool + signature → Archetype`. Keep saying *Sniper* at the
table — it is a readable name for a legal combination, not a slot in the system.

### combat-is-not-the-kernel
**Tempting.** Combat is the biggest, most-tested module, so its rules are the
real CUS and everything else is a variant.

**Why not.** Combat is the **reference implementation** — it exercises the most
primitives, which is exactly why it is dangerous. Every combat convenience
promoted to Kernel law is a tax on politics, trade, travel and crafting forever.

**Instead.** Law 12. Combat facts stay in B and stay retunable. If a rule can't
be stated without mentioning weapons, it is not Kernel law.

### formations-are-not-prescriptive
**Tempting.** A formation needs exact spacing, coherency distances, and a
transformation procedure, or players will argue.

**Why not.** That is measurement bureaucracy (Law 8) — precision bought at the
cost of every interesting decision. Rigid spacing also fights terrain, which is
where the whole game lives.

**Instead.** A Formation holds `Name · Picture · one sentence of intent`. Players
maintain the shape as closely as practical. MOVE translates it; Reform changes it.
Both reduce to existing verbs and Position changes.

### alternation-is-not-initiative
**Tempting.** Alternating activations is an initiative system, so it should be
rolled for or modified by stats.

**Why not.** Initiative asks *who goes first*. Alternation answers *where should
everyone be looking* — it is a camera, pointing attention at the hottest fight
and keeping both players in the game continuously.

**Instead.** Straight alternation. **But note:** activation order still carries real
weight, because **an armed WAIT expires the moment its figure activates.** Go early
and you spend the rest of the round holding nothing but what your weapon already
says; hold back and you keep a better answer primed. The camera has a clock. That is
emergent and good; it is not a reason to add initiative.

*(Until 2026-07-27 that clock was the Reaction pool refreshing on activation. The
pool is struck; the clock survived it, which is why this entry did.
`→ G·a-pool-is-not-a-position`)*

---

# The substrates

### position-is-not-a-resource
**Tempting.** Position is listed among the things a module can spend, so it is a
Resource like Agency or Supply.

**Why not.** You cannot spend Position. You can only **change** it — and changing
it is what MOVE is for. Filing it as a Resource implies a pool, a budget, and a
depletion rule, none of which exist.

**Instead.** Position is a **substrate**. It is strategically valuable without
being consumable. Giving up ground is a *change* with consequences, not a payment.

### force-is-not-a-stat
**Tempting.** Force is a primitive, so there should be a Force value you compare.

**Why not.** The moment Force is a number, every module needs a conversion rate
into it, and every asymmetric contest becomes a subtraction. It would flatten the
exact thing the four axes exist to keep in tension.

**Instead.** Force is a **formal primitive and non-numerical**. It is *read*
through `Role · Tempo · Tool · Temperament` and *expressed* by writing State,
Position, or a Resource. There is no Force stat and there is no Force roll.

### agency-is-not-autonomy
**Tempting.** "Squares trade agency for protection," so Squares have fewer AP.

**Why not.** They don't. A Square spends exactly the AP a Circle does. The word
was doing double duty, and one of the two meanings is a Kernel Resource.

**Instead.** **Agency = AP.** What a Square trades is **autonomy** —
self-determination: locked facing, breakable morale, no independent will once it
Routs. Say *autonomy* when you mean freedom and *Agency* when you mean points.

---

---

# The component layer

*(Cited from [Document J](J_COMPONENTS.md), the analog interface. Same rule: a
component never decides a mechanic, it only shows one.)*

### subtractive-beats-additive
**Tempting.** A richer game needs richer components — more tokens, more trackers,
more dials — and escalation should *add* them as the fight grows.

**Why not.** Play-time components are the tax you pay every turn, and they compound:
Zombicide did not drown in the bits that *existed*, it drowned in the bits that
**moved during play.** A system that adds a token per escalation is at its most
fiddly exactly when the board is most crowded and the decisions matter most.

**Instead.** Components should **decline** as the game escalates. State that can be
read off the model (orientation, sculpt) or off your hand (card count) costs nothing
to escalate. Reserve added hardware for the genuine exception — a Champion's second
Wound — and let everything else be read, not tracked. `→ G·encode-the-exception`

### encode-the-exception
**Tempting.** Every figure has a Nerve state, so every figure should carry a Nerve
marker — uniform, unambiguous.

**Why not.** Most of the board is **Steady** most of the time. A marker for the
default value pays full price for the null state: you place, carry, and read a token
whose entire message is "nothing has happened here." Multiply by every figure and the
table is papered in *no-ops*.

**Instead.** **Encode only the exception.** Steady gets no flag; a flag *appearing*
is the whole signal. The same logic runs the whole layer — Health is read from
orientation because *upright* is the default, Armour from the sculpt because it never
changes. Pay for change, never for the resting state.

### the-hand-is-not-a-deck
**Tempting.** The units are on cards and you hold them in your hand, so CUS is a
card game — shuffle, draw, discard, hand size, draw luck.

**Why not.** CUS is **deterministic** (A·XVI, *determinism as trust*). The moment a
card is *drawn* rather than *chosen*, variance enters the one place the design
promised there would be none, and "I couldn't act because I didn't draw him" becomes
a sentence. That is a different game, and a worse one for this engine.

**Instead.** The hand is a **status display, not a deck.** Nothing is shuffled,
drawn at random, or discarded. Hand thickness *shows* your remaining activations
(B·12); a card goes down when its figure acts and comes back next round. The card
handling is the activation economy made physical — no randomness smuggled in.

### the-model-is-the-marker
**Tempting.** Knocked Out, Dead, and "which way am I hurt" want tokens or a status
dial next to the model.

**Why not.** A token beside a model is a second copy of a fact the model could carry
itself — Law 1 at the table — and it drifts, gets knocked, and gets picked up with
the wrong base.

**Instead.** **The model is the marker.** Upright = fine, on its side = Knocked Out,
removed = Dead. The prone model *is* the rule that it rolls no Armour if hit again
(B·7) — the physical state and the mechanic are one fact in one place, which is
exactly what Law 1 asks for.

### the-base-does-not-lie
**Tempting.** A dramatic sculpt — outflung cloak, banner pole, a spear crossing the
rim — should count as part of the figure when you measure engagement and Reach.

**Why not.** The base is the **measuring instrument** (B·1, B·8, B·11). If scenery
can extend the contact perimeter, then engagement becomes an argument about where the
cloak ends, and two figures "touch" or don't based on how flashy their basing is.
The instrument has to be honest or every geometric rule downstream inherits the lie.

**Instead.** The Kernel reads the **base footprint and only the base footprint.**
Scenery on the base is decoration up to the rim and irrelevant past it; nothing a
figure carries extends its contact perimeter. Model the magnet wells *into* that
honest footprint (J·5) and the instrument stays trustworthy across every future
sculpt.

---

---

# Firearms, hordes & settings

*(Cited from [K · Firearms](K_FIREARMS.md), [L · Horde & Campaign](L_HORDE_AND_CAMPAIGN.md),
and [M · Sci-fi Setting](M_SCIFI_SETTING.md).)*

### one-engine-any-era
**Tempting.** Guns are a new thing, so firearms need their own subsystem — a shooting
phase, a ranged module, a separate set of verbs.

**Why not.** A gun reads and writes the same primitives a bow does — Position (range,
lane), a PACKET (dice, grades), State (a wound). A "firearms module" would be a second
combat engine, and a flintlock and an autogun would drift apart for no reason. Law 11:
translate, don't fork.

**Instead.** One **setting-agnostic engine** (K). A gun is a Ranged PACKET; the setting
picks the numbers and the skin. A musket and an autogun run identical math — only the
content differs. `→ G·misfire-is-heat`

### hybrid-is-two-packets
**Tempting.** A model with a rifle *and* a sword needs a mode: "ranged mode" and "melee
mode," with a rule to switch.

**Why not.** A mode is state you have to track and a switch is a rule that can be gamed.
The board already knows which one is legal.

**Instead.** A Hybrid figure just **holds two packets**, one Ranged, one Melee.
`not_in_contact` turns the gun off the instant a base touches yours — the **geometry**
does the switch, no rule fires. Sword-and-gun is the native case, not a special one.

### pin-is-per-mob
**Tempting.** Suppression is per-figure, so each pinned model carries a pin token.

**Why not.** A horde is forty cheap models. A token per pinned body is the exact
table-clutter the Component Law forbids (J · subtractive beats additive), and it is at
its worst when the board is most crowded.

**Instead.** Pin the **mob**, not the man — one shared token on the whole suppressed
unit. You suppress a *formation*, which is also how suppression reads in life.

### spray-is-ranged-cleave
**Tempting.** An assault rifle mowing a horde needs a new "auto-fire" rule with its own
targeting and its own cap.

**Why not.** The melee side already solved multi-hit — Cleave. Inventing a parallel
ranged one is two owners for one idea (Law 1).

**Instead.** Spray **is** Cleave at range: hop to the nearest fresh enemy, one die
fewer, until the dice run out. It self-terminates, and it only chains through a cluster —
**Position** caps it, not a number. `→ G·the-commitment-economy`

### a-grenade-is-indirect
**Tempting.** You should need line-of-sight to the spot you throw a grenade — you can't
hit what you can't see.

**Why not.** That is backwards. The whole point of a thrown or arcing weapon is that it
goes **over** the wall and **around** the corner. Demanding LoS turns a grenade into a
bad rifle.

**Instead.** **Blast is indirect** — target a point in range, no LoS, and let **scatter**
(K·5) be the price of firing blind. Direct LoS stays on bullets, where it belongs.

### a-resource-kind-is-not-a-mechanic
**Tempting.** Guns need an "Ammo" system and energy weapons need a "Heat" system — two
new mechanics, each owned by the combat rules.

**Why not.** "Ammo" and "Heat" aren't mechanics, they're **settings**. Freeze either
word into the engine and you've built a sci-fi term into a setting-agnostic rule — the
exact mistake the whole engine/content split (K vs M) exists to prevent. And they aren't
even two ideas: they're two **replenishment kinds** of the one Resource primitive the
kernel already has — finite (depletes, must be restored) and accumulating (rises, must
be vented). The tell: the finite kind was already needed for spell charges *before*
firearms existed, so a magazine reused it rather than inventing anything (Law 13).

**Instead.** The kernel carries three Resource **kinds** with neutral nouns —
**Agency** (renewing 🟢), **Charge** (finite 🟡), **Strain** (accumulating 🔴). A packet
is authored in the noun (`spend 2 Charge`, `gain 1 Strain`); the setting does one final
Presentation conversion so the card reads *"2 Ammo"* or *"reactor +1"*. Ammo, Heat,
arrows, mana, corruption are all skins. The engine only knows the kind. (A·IV)

### ammo-earns-its-tracker
*(A sub-case of the above: the finite kind, `Charge`, earns its tracker.)*
**Tempting.** Ammo counting is fiddly bookkeeping, and the Component Law says play-time
components are expensive — so drop it and let reload be a flat every-few-turns thing.

**Why not.** The **terror is the point**: a whole squad emptying on the same round and
reloading together as the wave hits. That drama only exists if ammo is **deterministic**
and trackable, so the failure is *avoidable* by staggering. A random or flat reload
throws the game away.

**Instead.** Accept **one** small tracker per gun (William signed off at this fidelity),
kept minimal: 2–4 ticks, the public part is just the card-down, the count is private.
The tracker earns its place because the reload economy *is* the mode.

### misfire-is-heat
**Tempting.** Blackpowder and energy weapons are different eras, so they need different
limiter systems.

**Why not.** They are the same shape — a risk that, on the bad result, **locks the
weapon** until you clear it. Building two systems doubles the rules for one idea.

**Instead.** **Misfire (blackpowder) and Heat (energy) are one mechanic, two skins.** A
fouled musket and an overheated plasma coil both go offline the same way (a card-down
cool-down). Ammo/magazine is the third limiter; a weapon carries whichever its era gives it.

### evasion-is-a-dodge
**Tempting.** "Hard to hit" should just be always-on cover — raise the shooter's success
number and move on.

**Why not.** Cover is beaten by volume and does nothing against the armour-piercing that
defines the gun meta. If Evasion were only cover, the sharpshooter faction would still
melt to a big enough ignore-Armour gun, and its whole identity ("you can't out-gun me")
would be a lie.

**Instead.** Evasion is a **dodge save** that works even vs ignore-Armour and blast — the
one defense bigger guns can't solve. The answer is to **corner** them (deny the escape
geometry), which is Position capping the fight again. Roll the better of dodge-or-armour,
never both.

### the-loop-is-the-kernel
**Tempting.** A campaign needs its own rules — a metagame layer bolted on top of the
battle game.

**Why not.** The Kernel's decision loop (A·XII: Observe → … → Persistence) already
*is* the campaign loop; it just usually runs inside one battle. A bolted-on metagame
would restate structure the Kernel owns.

**Instead.** Run A·XII at **campaign** scale: Story sets the mission, Combat resolves it,
Persistence scars the squad, the next Story inherits the grudge. Two modules at the
Figure, no new architecture. `→ G·intel-tilts-the-map-not-the-dice`

### the-horde-is-a-faucet
**Tempting.** A horde is just a big army — kill enough of it and you win, same as any
fight.

**Why not.** If killing hordelings were progress, the mode would be a math race against
spawn rate, and the answer would be "bring more dice" — a numerical solution the Kernel
keeps refusing.

**Instead.** The horde is a **faucet, not a bucket**: bodies recycle, so kills only buy
**time**. The real target is the **nest** or the clock — a **Position** problem (reach
and unmake it, or hold ground), which is the tool the Kernel actually wants.

### a-flood-needs-no-director
**Tempting.** To make a horde play well you need an AI director — a budget that spends
enemies, spikes pressure, stages a boss.

**Why not.** That is exactly `F_AI_DIRECTOR`, which was struck (E · kill-ai-director) as
a second, scripted mind on top of the Temperament the figures already have.

**Instead.** A flood is **emergent**: Temperament=Ravenous + spawn geometry + a thin
Mission. The pressure comes from the nests and the map, not a director. Nest-guardians
are Circles — the exception, not the return of the budget.

### attrition-is-the-clock
**Tempting.** The limiter on a survival mission is ammo — you win by not running out of
bullets.

**Why not.** Reload is a card-down (K·6), not a bullet count, so ammo never *ends* the
mission — it just paces a turn. Making ammo the mission clock would drag bullet-counting
back in.

**Instead.** The clock is **you**: wounds, scars (Doc H), and gear entropy grind the
squad down. The mission is a race between the nest's pressure and the squad's decay —
*can you last?* — which is what "survival" means.

### intel-tilts-the-map-not-the-dice
**Tempting.** Winning the pre-battle Story session should give combat **bonuses** —
+1 to hit, extra wounds, a buff.

**Why not.** Dice bonuses are the stacked numerical modifiers the Kernel avoids (A·II),
and they make the strategy session a stat-shop.

**Instead.** Intel and leverage are **scenario dials** — revealed lanes, a known enemy
plan, a starting position, an extra body, a sabotaged nest. They **tilt the map**, not
the roll, which is where CUS already puts balance (scenario, not stats).

### asymmetry-is-not-imbalance
**Tempting.** Fair means every faction wins ~50% against every other at equal points —
anything else is "unbalanced" and broken.

**Why not.** Forbidding hard counters forces every faction toward the middle: Tau can't
truly kite-or-die, Orks can't truly catch-or-fold, because a counter is an auto-win and
symmetry bans auto-wins. You would sand off the identities to hit a number.

**Instead.** **Asymmetry is content, not a bug.** Factions hard-counter each other, and
the **scenario** (map, objective, initiative, points-as-budget) balances a picked
matchup. This is what CUS already is — PvE-first, scenario-authored. The counter-web is
the strategy game. `→ G·the-fair-game-is-a-mirror`

### the-fair-game-is-a-mirror
**Tempting.** For a pure 50/50 skill test, you still need cross-faction balance so a
neutral match is even.

**Why not.** You never need it — and chasing it re-imposes the symmetry that flattens
identities (above).

**Instead.** The dead-even game is a **mirror**: both players bring the **same faction,
different sub-faction** (Chapter · Clan · Sept · Regiment). Identical chassis =
guaranteed symmetry; doctrine skins = variety that never touches balance. Space Marines
vs Space Marines, and let the better tactician win.

---

## Housekeeping

New entries go in the section they belong to, slug-cased, in the
**Tempting / Why not / Instead** shape. Cite from A–C as `→ G·<slug>` and delete
the defensive sentence you were about to write.

If an entry turns out to be about **old vocabulary**, it belongs in
[Document D](D_MIGRATION_MAP.md). If it is a **proposal that was refused**, the
ruling belongs in [Document E](E_OPEN_DECISIONS.md) — put the reasoning here and
link the two.
