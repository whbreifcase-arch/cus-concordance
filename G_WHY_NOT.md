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

**Instead.** Two distinct things, one shared cost:

```text
WAIT             player spends AP now to arm a chosen PACKET
Written Trigger  a PACKET carries its own trigger clause; no AP, no arming
                 ↓
both spend REACTION to resolve
```

Reaction is what unifies them — not a pretence that everything was armed.

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
wearing a vulnerability's coat. It also fractures the Reaction economy: suddenly
"every triggered PACKET costs 1 Reaction" needs an asterisk for people who have none.

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

**Why not.** The moment there is a procedure, there is a *checklist*, and the
most important thing a person can do for another person becomes a line item you
tick on the way to a stat correction. Players would optimise it. Someone would
work out the cheapest way to un-hollow a veteran and it would stop meaning
anything at all.

The design also does not need one. **Nothing in the rules closes the door** — it
is simply not marked. What a hollow man cannot do is exhaustively written; what
can be done *to* him, *for* him, or *near* him is not restricted anywhere, and
that asymmetry is deliberate. `hollow` describes a man's capacity, never the
world's.

**Instead.** Leave it emergent. Two standing instructions for anyone editing this
system:

```text
DO NOT sign-post it.   No "Redemption" heading, no procedure, no table entry.
DO NOT brick it up.    Hardening `hollow` is welcome — but every edit must leave
                       what OTHER figures may do unrestricted. He may be
                       impossible to reach. He may never be impossible to help.
```

This is the one place in CUS where the correct rules text is an absence. If a
group finds the way through, they will have found it themselves, and it will be
the best thing that ever happened at their table.

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

### counter-is-not-an-attack
**Tempting.** A Counter is an attack, so it should draw a Counter of its own.

**Why not.** It loops. Two figures with counter clauses would trade blows until
one died, on a single activation, with no player decision anywhere in the chain.

**Instead.** A Counter is a **response**, not a hostile ACTION. It does not draw
one back. *(Signed: E · counter-loop.)*

### reaction-is-not-agency
**Tempting.** Reactions come out of the AP pool — it is all just "stuff you can
do."

**Why not.** They answer different questions. AP is *what you do on your turn*;
Reaction is *what you can still answer with on theirs*. If they shared a pool,
every point spent attacking would silently lower your defence, and the whole
pre-contact game — spending your line down before the lines meet — would collapse
into one number.

**Instead.** Two pools, never converted. This is the engine of the commitment
game: `→ G·the-commitment-economy`.

### brace-is-not-an-ability
**Tempting.** Brace is powerful, so it should be a skill some units have and
others don't, printed on a card.

**Why not.** Then a shield wall becomes a keyword you either bought or didn't,
and the wall stops being about *where you are standing*. The whole point is that
formation is emergent geometry.

**Instead.** **Any Square may Brace.** It is universal and never printed. What
varies is whether bracing is a good idea where you are standing.

### the-commitment-economy
**Tempting.** These are seven unrelated rules: Reaction, the 3″ threshold,
interruption, Brace, Shield, discrete Grades, Disengage.

**Why not.** They are one idea found seven times. Every one of them says:
**you get one commitment, and committing forecloses something.** One answer per
round, then you are mute. One clean run, or the charge fumbles on the chaff. Lock
your facing, concede your flanks. Read one Grade line, lose the others.

**Instead.** Treat this as the design's thesis and use it as a test. *Does this
proposal create a commitment with a real foreclosure — or is it just a modifier?*
If it is just a modifier, it probably does not belong in CUS.

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

**Instead.** Straight alternation. **But note:** now that Reaction refreshes on a
figure's own activation, activation order carries real economic weight — when you
activate decides how long you sit with an empty pool. The camera acquired a
clock. That is emergent and good; it is not a reason to add initiative.

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

## Housekeeping

New entries go in the section they belong to, slug-cased, in the
**Tempting / Why not / Instead** shape. Cite from A–C as `→ G·<slug>` and delete
the defensive sentence you were about to write.

If an entry turns out to be about **old vocabulary**, it belongs in
[Document D](D_MIGRATION_MAP.md). If it is a **proposal that was refused**, the
ruling belongs in [Document E](E_OPEN_DECISIONS.md) — put the reasoning here and
link the two.
