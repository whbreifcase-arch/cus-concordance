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
- **Triggers (a shock):** the Square is **Wounded by an ATTACK**, **or** a **friendly
  figure within 3″ is slain or goes Broken.** One test per shock; a PACKET Effect may
  also force one.
- **The roll (in threes):** roll **3 dice**, success = the figure's **Nerve** number.
  **0** → step down the morale track · **1–2** → hold · **3** → step up.
- **Broken → Routs** by Temperament (B·10). **Rally** steps a figure up.

→ B·10.

## Also signed
**counter-loop.** A Counter is a *response*, not an ATTACK, so it does not itself draw
a Counter — two figures never loop forever. *(William confirmed.)* → B·9.

*(For the record, the earlier rulings — grades, traits, tools, temperament, force,
packet index, bases, engagement, counter, morale states — are documented in the
git history and mirrored in A/B/C. This register no longer holds open questions.)*

---

---

## Amendments — signed 2026-07-25 (William)

Six rulings, taken after an external consistency review of the published A–E set.
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

### On the wounds ruling
The earlier register parked this as "a tuning call for whenever William wants it."
He took it on 2026-07-25: *"Typically they will have 1 or 2 wounds, that's the
standard and it's a knob that gets twisted. Get rid of the fine hurt knockout and
dead. Knockout and dead are both states now, fine and hurt are not."* Fine/Hurt were
never State — they duplicated the number and violated Law 1. Gone.

### Still awaiting an owner ruling
```text
⚠ circle-scope   B·1 heads "One Circle per army" and then says "A Banner fields
                 exactly one Circle." An Army holds many Banners, so both cannot be
                 true. Left UNTOUCHED pending William. This is the one genuine open
                 item in v0.6.
```

---

### v0.6 is closed
No open constitutional questions remain beyond `circle-scope` above. The next change
to CUS is an **amendment**, recorded here as a new signed entry with its date — not a
blank awaiting a ruling.
