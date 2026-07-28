# CUS — DECISION REGISTER
### v0.6 · CLOSED · 2026-07-24 · amended 2026-07-25 · **2026-07-27**

> Every open decision is now **signed** (William, 2026-07-24) and folded into A/B/C.
> **CUS v0.6 is closed** — there are no unresolved constitutional questions. This
> register is kept as the record of what was decided and why; any *future* change is
> a fresh amendment, not an open item.
>
> **This document is the Decision Register.** The filename `E_OPEN_DECISIONS.md` is
> kept only so existing links and published URLs don't break — it is **not** a list
> of open decisions and has not been one since 2026-07-24. Cite it as *Document E ·
> Decision Register*.
>
> **Three statuses are used across A–F, and they are not the same thing:**
> ```text
> SIGNED         a closed owner ruling. Stable. Cite it.
> ⚠ PROVISIONAL  a SIGNED rule awaiting ratification in PLAY, not a ruling.
>                It is in force now; playing decides whether it stays.
> ⚠ OPEN         a genuine unanswered question. There are currently NONE.
> ```

## Status board — all signed ✅

| ID | Ruling | In |
|---|---|---|
| grade-accumulation | **Model 2 — Discrete** (Grade *N* resolves only its own Effects) | A·VI, B·5 |
| persistent-traits | **Traits** — referenced passive Definitions; keyword `trait` | B·14, C |
| tool-vocabulary | **Melee · Ranged · Hybrid** (vibe-check) | A·VII, B·1 |
| temperament | **Five words + leaderless/Broken behaviour table** | A·VII, B·10 |
| force-ontology | **Force IS a formal primitive** (non-numerical) | A·II, C |
| packet-classification | **Neutral ID + `packet_index` sidecar** | A·V |
| base-classes | **Small · Medium · Large** (no Monstrous, no Cavalry-class) | B·1 |
| engagement | **Bases touching = engaged · Reach 1–2″ · Disengage 1 AP** | B·8 |
| counter | **Turn-and-face · no cap · dying swing · Circles faceless** | B·9 |
| counter-loop | **A Counter does not itself draw a Counter** | B·9 |
| morale-states | **Steady → Shaken → Broken** (Broken = Rout by Temperament) | B·10 |
| nerve-trigger | **Shock triggers + 3-dice Nerve roll** (delegated → designed) — *reworked into the Mind channel: Nerve is now a **save**, Morale is damage (seventh batch)* | B·10 |

---

## The final ruling — nerve-trigger (delegated → designed)
William handed this one to me ("figure out what triggers a nerve check"). Designed to
read like every other CUS roll:

- **Who tests:** Squares of Creature Type **Man/Beast** only. Circles never test;
  Spirit & Construct never test (fearless).
- **Triggers (a shock):** the Square **loses a Wound to a hostile ACTION and lives**,
  **or** a **friendly
  figure within 3″ is slain or goes Broken.** One test per shock; a PACKET Effect may
  also force one.
- **The roll (in threes):** roll **3 dice**, success = the figure's **Nerve** number.
  **0** → step down the morale track · **1–2** → hold · **3** → step up.
- **Broken → Routs** by Temperament (B·10). **Rally** steps a figure up.

→ B·10.

## Also signed
**counter-loop.** A Counter is a *response*, not a hostile ACTION, so a Counter does
not trigger another Counter — two figures never loop forever. *(William confirmed.)*
→ B·9.

*(For the record, the earlier rulings — grades, traits, tools, temperament, force,
packet index, bases, engagement, counter, morale states — are documented in the
git history and mirrored in A/B/C. This register no longer holds open questions.)*

---

---

## Amendments — signed 2026-07-25 (William)

Eight rulings, taken after an external consistency review of the published A–E set.
v0.6 stays **closed**; these are amendments, not reopened questions.

| ID | Ruling | In |
|---|---|---|
| ~~reaction-resource~~ | ~~**Reaction is a Kernel Resource**, separate from and never paid out of AP. Every triggered PACKET costs 1~~ **STRUCK 2026-07-27** → `reaction-struck` | — |
| ~~reaction-budget~~ | ~~**1 per figure · 2 for a Circle**, refreshed at the start of the figure's own activation~~ **STRUCK 2026-07-27** → `reaction-struck` | — |
| counter-authoring | A Counter is a **Written Trigger inside a PACKET** — authored on the weapon/condition, not armed by WAIT, costs no AP | B·9, A·III |
| shield-cap | Shield intercept has **no artificial cap** — the limit is that he can die eating the hit *(revised 2026-07-27: the Reaction clause is struck)* | B·9b |
| brace-vs-overwatch | **Brace and Overwatch are the two WAITs.** Brace buys hard bonuses and step-ups; **Overwatch** = 1 AP to arm a better PACKET *(revised 2026-07-27: neither touches a Reaction pool, and arming is now permission)* | B·9b |
| sprint-to-charge | The **3″** is the **sprint→charge transition threshold** — a threshold, not a distance budget. Only physical contact interrupts | B·3, F |
| wounds | **Wounds is a number, not a track** — 1–2 standard, a tunable knob. *Fine* and *Hurt* are **deleted**; **Knocked Out** and **Dead** survive as the two real States at `wounds_remaining = 0` | B·7, C |
| circle-scope | **One Circle per Banner** (its Champion). An Army holds one Circle *per Banner*, not one in total | B·1 |

### On the wounds ruling
The earlier register parked this as "a tuning call for whenever William wants it."
He took it on 2026-07-25: *"Typically they will have 1 or 2 wounds, that's the
standard and it's a knob that gets twisted. Get rid of the fine hurt knockout and
dead. Knockout and dead are both states now, fine and hurt are not."* Fine/Hurt were
never State — they duplicated the number and violated Law 1. Gone.

---

## Amendments — second batch, signed 2026-07-25 (William)

Taken across a working session and a second external review. Several of these had
been ruled verbally and were carried in conversation before being written down —
which is why an outside reviewer graded a doc set that trailed the rulings. See
**Process** at the foot of this document.

| ID | Ruling | In |
|---|---|---|
| fists-standard | **Fists are standard equipment** on every figure — weak melee packet, never printed, carries the Counter trigger. Makes the Counter universal, with no condition but Position | B·5, B·9, C |
| reach-constraint | Reach is a **`not_in_contact` packet constraint**, not a measured dead zone. Strikes to X″, illegal while bases touch — in contact you swing Fists | B·8, C |
| ranged-in-melee | **Ranged carries `not_in_contact` by default.** Exceptions (wrist crossbow, hand flamer, point-blank spell) are authored and are a priced advantage | B·5 |
| simultaneous-death | If the ACTION and the Counter are both lethal, **both figures die.** No initiative tiebreak | B·9 |
| finish-the-downed | **A Knocked Out figure that is hit is killed and rolls no Armour.** Armour protects the standing only | B·7, C |
| morale-ratchet | **Breaking beats killing** — the one-way morale track is deliberate. Rally (a leader's ACTION) is the recovery valve, which makes decapitation a strategy | B·10, G |
| form-up | **Form Up** — a **Sergeant-only** group MOVE. Names unactivated friendlies within **4″**, shapes them, each pays **1 AP** and is **marked activated**; they MOVE as one body and declare strikes/Shoves **before contact**. The AP covers MOVE + attacks + Shoves; a formed-up figure still answers its written triggers. You hit only what your own base moves into (Reach excepted). Circles cannot call or join | B·11, C |
| form-up-pace | **A formation moves at the shortest Move among its members**, keeping shape as closely as practical. A body travels at the pace of its slowest man — so who you bring is a cost, and leaving someone out is a live decision | B·11 |
| move-stays-move | **The *Advance* alias is retired.** Combat does not rename MOVE. *Sprint · Leap · Withdraw* name kinds of MOVE | B·2, C, D |
| invocation-layer | **Verb ≠ invocation.** Player keeps three verbs; the grammar gains `WRITTEN_TRIGGER` and `OWNED_PROCEDURE` so Counter, Impact and Intercept reach the resolver honestly | A·XIV, C |
| round-boundaries | **START OF ROUND** defined: eligibility resets, the starting side alternates, that side picks first. Refresh stays **on activation** — hit the tired ones | B·12 |
| kill-ai-director | **F_AI_DIRECTOR deleted**, along with its play aids and its SLOT/Boss encounter budget. Nothing salvaged — the name is **deliberately cleared** for William's own campaign-preparation system (slot reserved, I·6) | — |
| domains | **Three co-equal domains: COMBAT · PERSISTENCE · MEANING**, peer modules intersecting at the Figure. *Story* is MEANING's everyday name. Rejected: *Bond* (one subsystem), *Identity* (too narrow), *Character* (collides with Creature Type / Archetype) | A·XIX, H, I |
| caravan-ownership | **Persistence is the module; the Caravan is the entity it operates on.** Caravan is *not* a flavour-name for the domain — it is a canonical hierarchy layer (A·X) and demoting it would give one concept two owners (Law 1) | H·2 |
| app-required | **Play is analog; Persistence requires the companion application.** A deliberate architectural commitment, not a fallback. Between-session bookkeeping is the app's job | A·XIX, H·4 |
| progression-location | **"Progression lives in the Caravan" is STRUCK.** Pure flavour wearing an ownership claim's clothes. **Progression lives in the Figure's Instance**; Persistence owns the procedures that change it | A·X, C, H·2 |
| caravan-physical | The **Caravan is the physical representation of the persistence axis** — a real model, read like a base (B·1): wagons, capacity, facilities, who is riding because they cannot walk | A·X, C, H·2 |
| harm-lifecycle | **WOUND → INJURY → SCAR (or RECOVERY).** Wounds are Combat's and transient; Injuries and Scars are Persistence's and persist. The fork is the existing `wounds_remaining = 0 → KO or Dead` | H·7 |
| harm-two-axes | **BODY and MIND, one lifecycle, different sources.** BODY harm comes from *damage* (Combat); MIND harm comes from *what happened* (Meaning). A figure can walk off untouched and ruined | H·7.2, I·5 |
| harm-granularity | BODY injuries are **generated, not enumerated**: `LOCATION × TISSUE × SEVERITY` → rolled ankle, broken ankle, torn achilles, dislocated shoulder, sprained wrist | H·7.3 |
| mind-scars-are-triggers | **A MIND scar is a Written Trigger** — structurally the same object as a grudge. No new machinery is required to make trauma work | H·7.4, I·5 |
| scars-change-not-subtract | **A scar should change *how* a figure fights, not merely subtract.** A bad ankle stops him chasing and teaches him to hold ground: −2″ Move, +1 die Braced. Veterans should be legible from their scars | H·7.5 |
| recovery-asymmetry | **BODY heals with care and time; MIND heals with relationships.** A figure with no Bonds does not recover from what he saw — his MIND injuries run to their neglect column and stay there. Being alone is a mechanical disadvantage, not a mood | H·7.8, I·5 |
| aftermath-rolls | **BODY = a Care check; MIND = a Nerve check.** Both use the existing **three-dice, count-successes** shape (B·10) so nothing new is learned. Care 6+ / 5+ surgeon / 4+ surgeon+facilities; 0 successes = died of wounds | H·7.3 |
| harm-tables | **Written 2026-07-25.** 6 locations × d6 = **36 BODY injuries** · **8 MIND injuries** keyed to triggers · **25 BODY scars + 10 MIND scars**. Every scar takes something and gives something | H·7.4–7.7 |
| hollow-hardened | **`hollow` gets its own section (H·7.7b) and teeth.** It **deepens** (Nerve worsens again every period ended with no friendly within 3″, without limit), it **cannot mend** (no ACTION that repairs anything between people — no Rally, no tending, no amends), and it **lashes out** (a Written Trigger: Wounded, or any figure downed within 3″ → he strikes the nearest figure, friend or foe, and does not choose it) | H·7.7b |
| rank-vs-control | **One word was carrying two predicates.** *Circle* meant both "exceptional Definition axis" and "the figure a player is running" — identical sets on the day both laws were drafted, and not identical since. Now split: **RANK** (Circle/Square — faceless, unbreakable, exceptional) and **CONTROL** (played by a person / run by the chair). Every sacred-figure law names its basis | I·6, B·10, G |
| circles-hold-is-control | **A PLAYED figure can be Yielded, never Moved. An NPC Circle CAN be Moved.** The law protects player sovereignty (Law 9 in the parlour), not hero-ness — so talking an enemy champion down is legal, hard, and campaign-shaping | I·6 |
| nerve-exemption-is-rank | **Circles never test Nerve because they are exceptional, and that holds for ENEMY Circles too.** Not a courtesy to players — a statement about what a champion is | B·10 |
| break-triggers | **A Circle never breaks by dice. It breaks by a prewritten trigger** — a Written Trigger authored on that figure in advance. **No trigger written = he fights to the end.** A break condition and a campaign hook are the same object, so one authoring format covers both | B·10, G |
| two-modules | **CUS has TWO modules: COMBAT and STORY** (2026-07-26). The earlier three-domain split (Combat / Persistence / Meaning) is **struck** — it was abstraction for its own sake. **MEANING is renamed STORY**, the word people actually use, and it absorbs the Social Module draft. Rejected: *Meaning*, *Social*, *Bond* | A·XIX, I |
| persistence-is-kernel | **Persistence is not a module — it is Kernel architecture**, and William is writing it into Document A. `H_PERSISTENCE.md` becomes a **holding pen**: its harm and aftermath procedures stay playable and should survive the move, but H may not be cited as a domain | A·XIX, H |
| after-the-battle | **The post-battle loop is written (H·8)** — the 5-line analog BATTLE RESULT (who went down · who died · what it cost · did you win · what happened), the six-step sequence, and finite care. **One battle = one period** as a deliberate clock stub | H·8 |
| care-is-finite | **TEND capacity: 1 / 2 with a field surgeon / 4 with surgeon + facilities.** Recovery only ticks in a period the figure was tended; go untended for as many periods as the injury's recovery cost and it converts to its Neglected outcome. *You have four wounded and two hands* — choosing who waits **is** the between-battle game | H·8.3 |
| hollow-cause-withheld | **The state is fully specified; the trigger is not published.** How a figure becomes hollow appears nowhere in A–I and is held privately by the owner. The neglect column of the MIND table routes to ordinary scars instead. Players are told *that* a figure is hollow, never *how* | H·7.6, H·7.7b |
| no-redemption-rule | **No redemption procedure is written, on purpose.** A procedure becomes a checklist, and the most important thing one person can do for another becomes a line item on the way to a stat correction. No *Redemption* heading, no table entry | G·there-is-no-redemption-rule |

---

## Amendments — third batch, signed 2026-07-27 (William)

**The Reaction economy is struck.** Taken after play. v0.6 stays **closed**; this is
an amendment, not a reopened question.

| ID | Ruling | In |
|---|---|---|
| reaction-struck | **Reaction is no longer a Kernel Resource.** The pool, the budget, and the per-trigger cost are deleted everywhere. Out-of-turn response is gated by **Position, authoring, and death** — never by a number | A·IV, A·XIV, B·9, B·12, C, D |
| counter-is-free | **A Counter costs nothing.** It is a Written Trigger on the defender's packet and it fires. Its four limits: **contact** (no contact, no Counter) · **facing** (an engaged Square answers only its front) · **authoring** (`provokes: false`) · **death**. A Counter still does not draw a Counter | B·9, C |
| provokes | **The striking packet decides whether it draws a Counter.** New packet field `provokes` — **true by default for a melee packet resolved in base contact**, false for everything else. A backstab, an assassination, a coup de grâce authors `provokes: false` instead of being special-cased in prose | B·5, B·9, C |
| trigger-once-per-occurrence | **A Written Trigger fires once per occurrence of the condition it names — and a movement is one occurrence.** A figure crossing a spearman's reach band is one event however many increments (F) it takes to cross. This is the anti-milking rule the pool used to supply | A·XIV, B·8, C, F |
| wait-buys-quality | **WAIT is the only AP-priced out-of-turn capability, and it buys quality, not permission.** Brace and Overwatch are the two WAITs. *"Arming is not permission"* is **struck** — with no pool to be empty, arming **is** permission | A·III, B·9b, C, G |
| facing-is-the-cap | **What replaces the pool is the front arc.** An engaged Square faces one enemy and answers what comes at that face; everyone reaching its flank or rear gets in free. A **Circle**, faceless, answers every attacker from every angle — which is what the two-Reaction Champion was clumsily saying | B·8, B·9, G |

### Why it was struck
Not because it was burdensome — because **Position had already answered the question
it was answering.** B·8/B·9 deny a Counter on an engaged Square's unfaced flank or
rear: that is the anti-overwhelm rule, and it is geometric. Reaction was a second,
numerical answer to a settled question — two owners for one job (Law 1) — and it ran
against A·II, which says depth comes first from Position and **not** from stacks of
numerical modifiers.

**What is knowingly lost.** Chaff sequencing: spending an enemy's Counters with
bodies before landing the real blow. With no pool there is nothing to spend. The
counterplay moves to **envelopment** — get around the shield wall rather than drain
it — which is the same answer the Kernel keeps giving. Accepted deliberately.

**What is knowingly risked.** Shield intercept and the reach opportunity strike are
now capped only by attrition and by `trigger-once-per-occurrence`. Both sit under the
⚠ PROVISIONAL flag on B·9b. **Playing decides.**

*(Note: the 3,000-game balance run that produced the current faction numbers was
measured on **uncapped** Counters. This amendment returns the rules to the state the
sim validated; adding Reaction is what departed from it. **No prices or costs are
repointed by this amendment.**)*

### On Form Up and the tempo trade
The consequence was raised before signing and accepted deliberately: forming up
eight figures burns eight activations in one beat of alternation, handing the
opponent an uninterrupted run. William: *"That's the point. That is how it's
supposed to work. So if you exhaust your entire guys at the beginning of the round
and the enemy hasn't and he's ready to push you. God speed."* Form Up is a
**round-level** commitment, not a figure-level discount. → `G·form-up-is-not-free`

---

## Amendments — fourth batch, signed 2026-07-27 (William)

**One working session: the Overwatch shot, Position as currency, the campaign
economy, and the physical component layer** — the last opening a new Presentation
document, **[J · The Component Layer](J_COMPONENTS.md)**. v0.6 stays **closed**;
these are amendments, not reopened constitutional questions.

| ID | Ruling | In |
|---|---|---|
| overwatch-exhaustible | **An armed Overwatch fires once and is spent** — one WAIT, one shot. A deliberate asymmetry with the free, repeatable Counter: a ranged facing *cone* covers a volume with no flank outside it, so a free lane would be absolute and screens pointless. Spent-after-firing is what makes the screen work | B·9b, J·2, G |
| shot-ladder | **Prior movement prices the Overwatch shot.** Which of **Quick · Normal · Precise** is available on the trigger is set at arming by what the model did this turn: sprinted to the lane → Quick only; held ground it already owned → Precise. Rebuilds *positionally* the tempo layer the struck Reaction refresh used to give | B·9b, G |
| position-is-currency | **Ground itself has value, so waiting costs you ground.** Lanes and threat projection are the core game; **screens answer lanes** (cheap bodies absorb what is downrange so the anchor crosses). A restatement of A·II — depth comes first from Position — now load-bearing at the table | A·II, B·9b, J·1 |
| no-lane-exempt-archetype | **No archetype is exempt from the lane.** An assassin must **tank the crossing** (armour that survives is correct), never skip it — teleport, reserve deployment, or an outsized move that makes the lane never apply is illegal design, because it exempts one figure from the game everything else is playing. The ecology (rangers → mobile armoured assassins → overwatched wizard) depends on it | B, factions, SCENARIO_PROMPT, G |
| entropy-is-the-leveler | **Entropy levels the snowball.** Gear breaks, boosts are temporary, lifestyle creep makes an elite roster unaffordable to sustain. This cleanly solves the mandatory-checklist problem — you cannot hold an optimal set together, so lists diverge on their own | H (economy) |
| retirement | **Accumulated scars and wounds eventually make a figure a liability** — he retires or dies in the field. The declining individual is a designed outcome, not a failure state | H·7, H·8 |
| progression-at-institution | **Individuals decline; the institution ascends.** The veteran blacksmith forges blades that break less easily; the settlement accrues what the character cannot keep. **Compatible with `progression-location`:** a Figure's Instance still *owns* its own progression mechanics (Law 1); the institution is simply another entity whose Instance accrues, and the *net economic arc* runs down for figures and up for institutions | H·2, A·X, cf. `progression-location` |
| component-law | **The six-principle Component Law is signed** (read-test · three homes · subtractive>additive · setup-cheap/play-expensive · encode-the-exception · the base is the instrument). It is the generator behind the card model, the on-model state table, and the base | J·1 |
| three-homes | **State lives on the model · Capability lives on the card · Campaign lives in the app.** The load-bearing split of the whole physical layer | J·1, J·6 |
| one-card-per-unit | **One printed card per unit** — front player-facing, back Kernel-grammar packets; **only what varies between figures** goes on the card, universal constants (AP = 3) on the laminated reference sheet. Champions get bespoke cards. Cards hold no runtime state (Law 5) | J·2 |
| cards-are-hand-management | **Holding the cards IS the activation economy.** Hand thickness = remaining activations; put a card down on activation, pick it up next round; a **facedown card at a model = the WAIT trap** (hidden info, no draw variance — the hand is a status display, not a deck) | J·3 |
| on-model-state | **The on-model encoding table is signed** — Activation (tall wire flag, present/gone/gone+card), Nerve (swappable flag, **Steady gets none**), Health (model orientation: upright/on-side KO/removed dead), Armour (WYSIWYG sculpt), AP (in your head) | J·4 |
| base-construction | **Base spec signed** — two recessed magnet wells sculpted as terrain; **boolean one modelled well into every base**; **poka-yoke diameters (2 mm / 1.5 mm)** so a Nerve post cannot enter the Activation hole; socket walls take the torque and the magnet only the lift; chamfered mouths; marked polarity; three-or-four variants | J·5 |
| base-is-the-instrument | **Nothing may extend the contact perimeter.** The base is the measuring instrument; engagement, Reach, `not_in_contact` and Form Up read base geometry and only base geometry — scenery on the base is decoration to the rim and irrelevant past it | J·5, B·1, B·8, B·11 |
| multi-area-maps | **Multi-area maps are a requirement, not a preference.** A single decisive point reintroduces the freeze (both sides correctly refuse to move); several places to be dissolves the stall. **Written into the scenario generator's hard constraints** so AI authoring cannot hand back a one-bridge map | SCENARIO_PROMPT, F |

### Why the Overwatch asymmetry
The Counter is free because its two limits — **short reach** and a **facing arc a
flanker can leave** — already cap it geometrically (the 2026-07-27 strike). Neither
limit exists down a firing lane: the cone is long and covers a volume with no flank
outside it. So the lane is priced and exhausts where the melee arc is free and
repeats. Same principle (Position caps out-of-turn response), two geometries, two
prices. → `G·overwatch-is-not-free`

### On progression — no contradiction with `progression-location`
`progression-location` (second batch) struck *"progression lives in the Caravan"* and
ruled that **the Figure's Instance owns its progression mechanics.** `progression-at-
institution` is an **economic** claim, not an ownership one: over a campaign, entropy
runs the *individual's* net arc **down** while durable gains accrue to *institutions*
— themselves entities with their own Instances. Both hold. The ownership law is
unchanged; the economy is the new statement.

---

## Playtest watch-list — ⚠ PROVISIONAL / design-watch (2026-07-27)

> **These do not reopen v0.6.** Every item below is either a **signed rule being
> watched in play** (⚠ PROVISIONAL) or a **tuning knob resolved by data, not by a
> constitutional ruling.** No constitutional question is open. The owner marked these
> *"for the table, not the whiteboard."*

| ID | The watch | If it bites |
|---|---|---|
| free-facedown | An **untriggered facedown costs nothing** — waiting and bluffing are both free. Pinning logic softens it (a locked chokepoint just ties up its holders while play resolves elsewhere) | **A facedown stays committed until that figure's next activation** (J·3) |
| shove-load-bearing | **Shove/Push is now the primary answer** to a face-locked chokepoint defender (B·9b). Its weight went up; it is still ⚠ PROVISIONAL | Retune Shove X/Y or its Grade line (B·9b) |
| form-up-stress | **Form Up (B·11) is the stress case** for every component decision — eight figures as one body is where loose dice, flags and footprints get tested at once | Simplify the formation handling before the flags |
| upkeep-curve | **Superlinear vs. proportional upkeep.** Entropy *slows* the snowball; only upkeep that scales **faster than winnings** *reverses* it. The two look identical on a whiteboard and diverge over ~10 sessions. **Intent signed** (upkeep must bend the curve down); the exact curve is a **tuning knob**, resolved by data | Steepen upkeep until the arc bends down in play |
| champion-wounds | **A Champion with >1 Wound needs somewhere to count it** — the one place a model may need an added counter. They are the figures getting bespoke cards; the count may live on the card | Add a wound track to the Champion card, not the model |
| lost-tempo-read | RP's refresh-on-activation created a **"hit the tired ones"** read (B·12). The shot ladder recovers *part* of it, not all — watch whether the missing part is missed | Author a movement-based read elsewhere if play wants it |

---

## Amendments — fifth batch, signed 2026-07-28 (William)

**Firearms, the horde-survival mode, four sci-fi factions, and the campaign loop.** A
working session that added the ranged-warfare engine and switched on the two-module
campaign cycle. v0.6 stays **closed**; these are amendments. New documents:
**[K · Firearms](K_FIREARMS.md)**, **[L · Horde & Campaign](L_HORDE_AND_CAMPAIGN.md)**,
**[M · Sci-fi Setting](M_SCIFI_SETTING.md)**.

| ID | Ruling | In |
|---|---|---|
| firearms-are-packets | **A gun is a Ranged PACKET, not a subsystem.** No shooting phase, no new verb. `not_in_contact` + `provokes:false` are automatic; Hybrid = two packets, geometry switches modes. The firearm ENGINE is setting-agnostic — a flintlock and an autogun run the same math | K·1, B·5, B·8 |
| gun-grade-ladder | **A shot climbs a grade ladder of different effects: Suppress/Pin → Wound → Cripple/Kill.** You may shoot to pin, not just to wound; dice decide how high you climb | K·2, B·6 |
| pin-and-suppress | **Grade 1 stops the target two ways.** PIN (physical State — loses AP / can't advance) works on the fearless; SUPPRESS feeds the existing Nerve track (B·10) against breakable men. Pin is **per-mob** (one shared token), never per-model | K·3, B·10, J |
| spray | **Spray = the ranged twin of Cleave.** Walk the blob: each hop → nearest unhit enemy within 3" of the last, −1 die, until dice run out. Dice do triple duty (accuracy + chain + severity); it burns extra ammo | K·4, B·6 |
| blast-and-scatter | **Blast = the one new PACKET effect type** — an indirect (NO line-of-sight) template with concentric 1/2/3" bands writing bonus dice, each figure its own roll. SCATTER drifts it (shot-ladder-gated, min 1 step); friendly fire is ON | K·5, B·9b |
| ammo-and-reload | **Ballistic weapons run dry; reload = the card going down (J·3).** Magazine = a few shooting-activations (sci-fi); muzzle-loaders are single-shot (blackpowder). The DELIBERATE terror is the whole squad reloading at once — stagger it | K·6, J·3 |
| misfire | **Blackpowder's limiter is MISFIRE/fouling** — a risk roll that locks the weapon (card-down to clear). The powder-era twin of Heat: same rule, different skin | K·6 |
| heat | **Energy weapons run HOT, not dry.** Pushing (overcharge/spray) adds heat; the cap = OVERHEAT (weapon locks) and for plasma "gets hot" = a Wound to the bearer (a Persistence/Doc H scar hook). Ammo pressures logistics, heat pressures discipline; mixed squads self-stagger | K·7, H |
| overcharge | **A universal lever: spend the limiter for a bigger shot** (+1 die or ignore-Armour), paid in extra ammo-step / extra heat / higher misfire | K·8 |
| evasion | **Evasion = a DODGE save die** that beats even ignore-Armour and blast — roll the better of dodge-or-armour, never both. The counter to the armour-piercing meta; you must CORNER an evasive figure, not out-gun it | K·9, M·3 |
| trackers-accepted | **Ammo/heat use play-time trackers, and that is accepted** at this fidelity (William: "at this level it's ok if we use trackers"). The public part stays the card-down; the count is private/light | K·6, K·7, J |
| horde-engine | **The horde is a FAUCET, not a bucket** — nests spawn, dead hordelings recycle, killing is time-buying. Win = survive / destroy the nests. Scenario dial: endless vs finite pool. This fills the reserved AI-director slot | L·3, L·5, E·kill-ai-director |
| horde-ai | **A flood needs no director** — hordes run on Temperament=Ravenous + a thin Mission (Law 9). The struck F_AI_DIRECTOR is not resurrected; nest-guardians are Circles | L·4, B·10 |
| campaign-loop | **The pre-mission STORY session sets the mission.** Story (Doc I, campaign use) → intel/leverage → scenario-generator inputs → Combat → Persistence → the next Story. A·XII at campaign scale, AI as GM. Doc I stays PROPOSED; its campaign USE is wired | L·1, L·2, A·XII, A·XIX, I |
| setting-split | **One engine, content per era.** The firearm engine is setting-agnostic; FANTASY fields blackpowder, the SCI-FI setting (M) fields autoguns/plasma. You never mix eras in one warband | K·11, M |
| four-factions | **Four sci-fi factions locked** (archetypes, not tuned prices): Marines (golden elite, no-fear) · Guard (combined arms, artillery, Orders) · Tau (Evasion, kite) · Orks (Mob + berserker, 3 wounds/no shrug). Each = a distinct answer to the horde | M·1–4 |
| matchups-asymmetric | **PvP is asymmetric, balanced by SCENARIO, not stat symmetry.** Factions hard-counter each other on purpose; the map/objective/points-budget balance a picked matchup. The 50/50 mode is a MIRROR (same faction, different sub-faction/Chapter) | M · matchup philosophy |
| ork-durability | **Orks get an extra heart (3 Wounds), NO Shrug save** (William, 2026-07-28: "there is no shrug, give em an extra heart"). They tank on raw meat, not a dice gimmick | M·4 |

### On the campaign loop and Story
The pre-mission strategy session is not new architecture — it is **Document I (Story)**
in campaign use, the peer module the Kernel already declared (A·XIX). Wiring its
outcomes into the scenario generator completes the OBSERVE→…→PERSISTENCE loop (A·XII) at
campaign scale. Story remains **PROPOSED/unsigned** as a module; only its campaign
*use* is wired (L·2).

### On the setting split
The firearm engine (K) is Kernel-level and setting-agnostic — Combat is the reference
implementation, not the definition (Law 12). Blackpowder and autoguns are **content**,
and content is where a setting lives. The sci-fi factions (M) are a content pack, not a
change to the fantasy world.

---

## Amendments — sixth batch, signed 2026-07-28 (William)

**Ammo and Heat were never mechanics.** Taken the same day, after the fifth batch shipped
them as named systems: they are two behaviour **kinds** of the existing Resource
primitive, and the kernel should carry the kinds while settings name the skins. v0.6
stays **closed**; this refines the fifth batch, it does not reopen anything.

| ID | Ruling | In |
|---|---|---|
| resource-dynamics | **A spendable Resource is classified by how it replenishes** (Law 10) — three kinds with neutral kernel nouns and canonical colours: **Agency** (renewing 🟢, = AP), **Charge** (finite 🟡), **Strain** (accumulating 🔴). Packets are **authored in the nouns** (`spend 1 Charge`, `gain 1 Strain`) and **skinned at Presentation** per setting. Scopes **costs** only — Health and Morale stay State (Law 1) | A·IV, C |
| ammo-is-a-skin | **"Ammo" is the sci-fi Presentation skin of Charge**, not a mechanic. A ballistic weapon `spends Charge`; the card shows a magazine; reload = restore Charge = card-down (J·3). Reframes the fifth-batch `ammo-and-reload` row | K·6, C |
| heat-is-a-skin | **"Heat" is the sci-fi Presentation skin of Strain**, not a mechanic. An energy weapon `gains Strain`; at the cap the authored consequence fires (overheat/gets-hot). Reframes the fifth-batch `heat` row | K·7, C |
| colour-plus-shape | **The three kinds are shown by colour AND shape**, never hue alone — the poka-yoke rule from the Component Layer (J·5), so the vocabulary survives colour-blindness and bad light | A·IV, J |

### Reframed from the fifth batch
```text
ammo-and-reload  → skin of Charge (resource-dynamics). Reload = restore Charge.
heat             → skin of Strain (resource-dynamics).
misfire          → a risk twist on a Charge weapon (unchanged behaviour).
overcharge       → spend extra Charge OR gain Strain (unchanged behaviour).
```
The fifth-batch rows stay in the record; these say what they *are* now.

### Why it was taken
William: *"Neutral nouns and kernel language. When the packets are written they get
converted one last time — spend two Charges, and the flavor reads 2 Ammo."* That is the
Definition→Presentation split (A·IX) applied to costs. Naming the engine after a setting
("Ammo") was the fifth batch's one impurity; this removes it. The abstraction was already
load-bearing — the finite kind predated firearms (spell charges), which is the Law-13
sign it sits at the right layer. `→ G·a-resource-kind-is-not-a-mechanic`

---

## Amendments — seventh batch, signed 2026-07-28 (William)

**The channel rework + the gunplay audit.** Auditing the firearms revealed that almost
every "new" gun mechanic dissolves into existing grammar once Morale becomes a *channel* —
and that revealed the Body/Mind/Soul triad and a new architectural law. The biggest
structural batch. v0.6 stays **closed**.

| ID | Ruling | In |
|---|---|---|
| morale-is-a-channel | **Morale is the Mind channel, reworked from a test into damage.** An attack deals `N Morale`; **Nerve** is a psychic-armour *save* (None/L6+/M5+/H4+); each unsaved point steps Steady→Shaken→Broken. No 3-dice test. Rally heals; Circles + fearless immune | A·II, B·10, C |
| nerve-is-a-save | **Nerve is psychic armour** — the same tiered save as Armour, applied to the Mind. A figure's Body-toughness and Mind-toughness are independent | A·II, B·10 |
| fear-is-contagion | **The fallen are an area Morale source** (a friendly slain/KO/Broken within 3″ deals Morale to nearby breakable figures), **batched in one sweep at end of strike.** This contagion is what makes Mind a channel; it scales up (a hive's recycle economy = its Nerve) | B·10, L |
| ~~morale-is-not-attrition~~ | **STRUCK.** The anti-attrition guardrail is deleted on purpose — grinding a line's Morale down is now legitimate play; if a player finds the grind, that *is* the intent | G (deleted) |
| body-mind-soul | **Three channels of harm: BODY · MIND · SOUL**, each a State track with a save and a three-state terminal. Body/Mind are symmetric and live; **SOUL is reserved** | A·II, C, H |
| soul-reserved | **SOUL — a formal, undefined Kernel primitive, permanently blank.** Never named, called, triggered, read, or state-changed. *Do not define or alter it under any circumstances, ever.* Witnessed only where Body and Mind interact (cf. Force). **Tripwire (this line):** the blank is *intentional and signed* — never "fix" it | A·II |
| exception-is-a-named-field | **NEW architectural law (A·XV·15): an exception may only exist as a named, owned field, never as prose.** Test: can it be a field? yes → the container (`provokes`, `los`, a trait, a G-slug); no → it's a missing layer (Principle 8) | A·XV, G |
| stun | **Stun = the universal "temporarily stop the agent"** (suppression/pin/root/immobilize/petrify): knock the figure one step down the activation flag (ready→waiting→spent), recovers next activation. Rides the flag, no new marker, **works on the fearless.** Retires the "Pin" state | B·12, K·3, J |
| ~~pin-state~~ | **STRUCK.** Pin as its own State is gone — Stun covers the physical stop, Morale the fear, neither needs a bespoke marker | K·3 (was `pin-is-per-mob`) |
| unpierceable | **Evasion/Bulwark are not a new save** — a save carrying the **`unpierceable`** tag (`ignore Armour` can't bypass it). Evasion (dodge) + Bulwark (shield) are two skins of the one tag | B·7, K·9, M |
| ~~evasion-dodge-save~~ | **REFRAMED** to `unpierceable` (above) — one tag, not a "roll better of two saves" | K·9 |
| spray-is-ammo | **Spray drops the −1-die falloff** — each hop is a full roll costing **1 Charge**; a 3-Charge weapon sprays up to 3 targets, tying the horde-sweeper to the reload economy | K·4 |
| charge-strain-0-3 | **Charge and Strain are 0–3 tracks.** Charge spent down (each shot 1; reload = card-down). **Strain builds up and POPS at 3** → roll VENT vs BLOW-UP (gets-hot = a Wound to the bearer); overcharge always pops | K·6, K·7 |
| blast-parameterized | **Blast is a fully-authored delivery method** (Law 15): `los` · `path` (over cover, not through solid) · `bands` (per-ring width, default [1,1,1], zero-inner allowed) · `dice` 3/2/1 by ring · `accuracy` scatter. Delivers any grade-line effect (frag=Wound, flashbang=Stun, gas=Morale). Indirect, friendly-fire ON | K·5, A·XIV |
| scatter-random-walk | **Scatter = random walk + misses-become-drift.** Shot tier (Quick/Normal/Precise, the shot ladder) sets a baseline (3/2/1 steps); each missed accuracy die adds a step; arrow-dice, one direction per step. Aim = the shot ladder, not a new mechanic | K·5 |
| one-flag-one-owner | **One stoplight flag** carries activation: green ready · yellow waiting · gone spent; card goes down. Kills the card/flag double-encoding (a Law-1 break at the physical layer) and its desync error class. Nerve palette kept off green/yellow | J, B·12 |
| los-path-params | **Targeting legality is packet fields** — `los` (line of sight) and `path` (a clear trajectory), general to all packets, not just blast | A·V, A·XIV |

### On the gunplay audit
The whole point: with Morale a channel and Stun on the flag, the *only* genuinely-new
mechanic in the entire gun kit is **Blast** — and even that is pure packet-data. Suppress,
Stun, Spray, Overcharge, Ammo, Heat, Evasion and Overwatch all dissolved into existing
kernel grammar. That is the exception-container law (A·XV·15) working: you don't fight
exceptions, you give them named fields.

---

## Amendments — eighth batch, signed 2026-07-28 (William)

**The fourth pillar: [Document N · The Digest](N_DIGEST.md).** The loop closes —
legislation (A–M), rulings (E), rationale (G), and now **jurisprudence** from adversarial
contact. v0.6 stays **closed**.

| ID | Ruling | In |
|---|---|---|
| the-digest | **CUS has a jurisprudence register — the Digest.** Discovered play from adversarial contact is recorded as typed, owned entries (Law 15), not FAQ prose. It records and judges; it changes no rule by itself. Named for Justinian's Digest — law with an amendment process is the durable Roman infrastructure | N, README |
| the-verdict | **Every entry is judged DEGENERATE or TECH** — the one field a tool cannot set (Law 10: a judgment, signed). DEGENERATE (collapses decision-space) → remedy it; TECH (expands it — squelch, the wavedash) → **promote it to canon.** Auto-preventing everything strangers find would sterilise the emergence the system exists to produce. Verdicts can be re-judged | N·2 |
| remedy-ladder | **A DEGENERATE entry is repaired at the cheapest rung that holds** — (1) authoring constraint (the scenario generator denies the geometry) → (2) price (balance.py) → (3) packet field (data) → (4) constitutional amendment (signature). Each rung is a different layer's tool; most exploits die at 1–2 without the law feeling it | N·3 |
| ci-for-legislation | **Every Digest entry becomes a sim policy** — a scripted regression test re-run on every future signing. A later amendment that silently re-opens a closed exploit (or deletes a promoted tech) **fails the run.** Extends the existing `scenarios.py` mechanic-assertions. This is how a one-person system survives contact for decades | N·4, factions/sim |

### On closing the loop
The Digest is A·XII (the Kernel's decision loop) run at the **design** level: legislation
proposes, rulings decide, rationale defends, and jurisprudence learns from contact and
feeds all three — a promoted TECH becomes a G-slug, a rung-4 remedy becomes a signed
amendment here. It turns a thousand strangers into co-authors, one signed verdict at a time.

---

### circle-scope — SIGNED (William, 2026-07-25)
B·1 previously headed "One Circle per army" and then said "A Banner fields exactly
one Circle." An Army holds many Banners, so both could not be true.

> **Ruling: one Circle per Banner.** Each Banner fields exactly one Circle — its
> Champion. An **Army** holds **one Circle per Banner**, not one in total.

This matches the built content: all seven CUS_FACTIONS warbands field exactly one
Champion, and non-champion Circles were already converted to Squares. Only the
heading was wrong. → B·1.

**No open items remain.**

---

## Process — how a ruling gets here

Three separate outside reviews have now graded a document set that trailed the
rulings, because calls were made in conversation and folded into A–C days later.
That is a process bug, not bad luck.

> **A verbal ruling is written into this register the same day it is made** — as a
> row in the current amendments table — **before** it is folded into A/B/C. The
> register may run ahead of the rules documents; it must never run behind the
> conversation.

---

### v0.6 is closed
**No open constitutional questions remain.** The next change to CUS is an
**amendment**, recorded here as a new signed entry with its date — not a blank
awaiting a ruling.
