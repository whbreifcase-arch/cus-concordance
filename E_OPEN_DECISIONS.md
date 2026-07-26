# CUS — DECISION REGISTER
### v0.6 · CLOSED · 2026-07-24 · amended 2026-07-25

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
| nerve-trigger | **Shock triggers + 3-dice Nerve roll** (delegated → designed) | B·10 |

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
| reaction-resource | **Reaction is a Kernel Resource**, separate from and never paid out of AP. Every triggered PACKET costs 1 | A·IV, C |
| reaction-budget | **1 per figure · 2 for a Circle**, refreshed at the start of the figure's own activation | B·12 |
| counter-authoring | A Counter is a **Written Trigger inside a PACKET** — authored on the weapon/condition, not armed by WAIT, costs no AP | B·9, A·III |
| shield-cap | Shield intercept has **no artificial cap** — the limits are that he spent his Reaction and that he can die eating the hit | B·9b |
| brace-vs-overwatch | **Brace grants no Reaction** (hard bonuses and step-ups only). **Overwatch** = 1 AP to arm a better PACKET, and **still spends the Reaction** when it fires | B·9b |
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
| fists-standard | **Fists are standard equipment** on every figure — weak melee packet, never printed, carries the Counter trigger. Makes the Counter universal with one condition (Reaction) | B·5, B·9, C |
| reach-constraint | Reach is a **`not_in_contact` packet constraint**, not a measured dead zone. Strikes to X″, illegal while bases touch — in contact you swing Fists | B·8, C |
| ranged-in-melee | **Ranged carries `not_in_contact` by default.** Exceptions (wrist crossbow, hand flamer, point-blank spell) are authored and are a priced advantage | B·5 |
| simultaneous-death | If the ACTION and the Counter are both lethal, **both figures die.** No initiative tiebreak | B·9 |
| finish-the-downed | **A Knocked Out figure that is hit is killed and rolls no Armour.** Armour protects the standing only | B·7, C |
| morale-ratchet | **Breaking beats killing** — the one-way morale track is deliberate. Rally (a leader's ACTION) is the recovery valve, which makes decapitation a strategy | B·10, G |
| form-up | **Form Up** — a **Sergeant-only** group MOVE. Names unactivated friendlies within **4″**, shapes them, each pays **1 AP** and is **marked activated**; they MOVE as one body and declare strikes/Shoves **before contact**. The AP covers MOVE + attacks + Shoves but **never Reaction**. You hit only what your own base moves into (Reach excepted). Circles cannot call or join | B·11, C |
| form-up-pace | **A formation moves at the shortest Move among its members**, keeping shape as closely as practical. A body travels at the pace of its slowest man — so who you bring is a cost, and leaving someone out is a live decision | B·11 |
| move-stays-move | **The *Advance* alias is retired.** Combat does not rename MOVE. *Sprint · Leap · Withdraw* name kinds of MOVE | B·2, C, D |
| invocation-layer | **Verb ≠ invocation.** Player keeps three verbs; the grammar gains `WRITTEN_TRIGGER` and `OWNED_PROCEDURE` so Counter, Impact and Intercept reach the resolver honestly | A·XIV, C |
| round-boundaries | **START OF ROUND** defined: eligibility resets, the starting side alternates, that side picks first. Refresh stays **on activation** — hit the tired ones | B·12 |
| kill-ai-director | **F_AI_DIRECTOR deleted**, along with its play aids and its SLOT/Boss encounter budget. Nothing salvaged — the name is **deliberately cleared** for William's own campaign-preparation system (slot reserved, I·6) | — |
| domains | **Three co-equal domains: COMBAT · PERSISTENCE · MEANING**, peer modules intersecting at the Figure. *Story* is MEANING's everyday name. Rejected: *Bond* (one subsystem), *Identity* (too narrow), *Character* (collides with Creature Type / Archetype) | A·XIX, H, I |
| caravan-ownership | **Persistence is the module; the Caravan is the entity it operates on.** Caravan is *not* a flavour-name for the domain — it is a canonical hierarchy layer (A·X) and demoting it would give one concept two owners (Law 1) | H·2 |
| app-required | **Play is analog; Persistence requires the companion application.** A deliberate architectural commitment, not a fallback. Between-session bookkeeping is the app's job | A·XIX, H·4 |

### On Form Up and the tempo trade
The consequence was raised before signing and accepted deliberately: forming up
eight figures burns eight activations in one beat of alternation, handing the
opponent an uninterrupted run. William: *"That's the point. That is how it's
supposed to work. So if you exhaust your entire guys at the beginning of the round
and the enemy hasn't and he's ready to push you. God speed."* Form Up is a
**round-level** commitment, not a figure-level discount. → `G·form-up-is-not-free`

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
