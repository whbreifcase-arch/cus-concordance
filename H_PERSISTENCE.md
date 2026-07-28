# CUS — THE PERSISTENCE MODULE

### v0.6 · 🚧 HOLDING PEN — awaiting absorption into the Kernel 🚧

> ```text
> ┌─────────────────────────────────────────────────────────────┐
> │  §7 HARM and §8 AFTER THE BATTLE are WRITTEN and RUNNABLE.  │
> │  You can play a campaign on them with a pencil.             │
> │                                                             │
> │  Everything else is still a DOOR, not a room.               │
> │  Where this conflicts with A–G, A–G wins.                   │
> └─────────────────────────────────────────────────────────────┘
> ```
>
> **What this is.** ⚠ **NOT A MODULE.** Persistence is Kernel architecture, and
> **William is writing it into Document A** (A·XIX). This file is a HOLDING PEN:
> the harm and aftermath procedures are playable and should survive the move, but
> nothing here may be cited as a domain.

---

# 1 · What Persistence owns

```text
FIGURE          lasting injuries · scars · advancement · experience
                equipment carried · conditions that outlive a battle
                availability (fit / recovering / dead / missing)

CARAVAN         supplies · wealth · beasts · wagons · civilians
                crafting facilities · roster · what survived

WORLD           what changed and stayed changed · the campaign clock
```

**Persistence records truth. It does not decide what that truth meant** — that is
**Story's** job (Document I), and the split is deliberate.

---

# 2 · Persistence is the module; the Caravan is the entity

```text
Combat       is the module.   Figure · Banner   are what it operates on.
Persistence  is the module.   THE CARAVAN       is what it operates on.
```

The Caravan is a canonical hierarchy layer (A · X) and a **real model on the table:
the physical representation of the persistence axis.** Wagons, capacity, facilities,
who is riding because they cannot walk. You read it the way you read a base (B · 1).

> **"Progression lives in the Caravan" is struck — SIGNED (William, 2026-07-25).**
> It was pure flavour wearing an ownership claim's clothes, and it is what made an
> outside reader conclude the Caravan *was* the domain. **Progression lives in the
> Figure's Instance.** Persistence owns the procedures that change it. The Caravan
> is where those figures physically are.

---

# 3 · Verb translation  *(the module contract's load-bearing clause)*

```text
KERNEL   MOVE                  ACTION                      WAIT
Persist  travel — the Caravan  tend · craft · trade ·      hold in reserve —
         relocates, marches,   recruit · repair · train    bank supply, keep a
         makes for the pass                                bed open, stand watch
```

---

# 4 · The interface commitment — SIGNED (William, 2026-07-25)

```text
PLAY         is analog.   Miniature · card · dice · pencil. No screen at the table.
PERSISTENCE  requires the companion application.
```

A **deliberate architectural commitment, not a fallback.** The analog floor covers
*playing the game*; it does not extend to *maintaining the campaign*.

Consequence to design against: **a printed QR code cannot be written to.** Whatever
the payload schema becomes (§9.2), the physical code is fixed at print time.

---

# 5 · The contract with Combat

```text
PERSISTENCE ──▶ COMBAT INPUT ──▶ [ SEALED RESOLVER ] ──▶ DELTAS + EVENTS ──▶ PERSISTENCE
```

**In** — who is available, what they carry, what condition they are in. Constrained
intent for an AI force is already a **Mission** (A · XI), so the input contract
should *produce a Mission*, not invent a parallel object.

**Out** — state deltas and event records.

> ⚠ **The output contract needs an analog tier.** If it exists only as JSON it works
> for two sessions and then dies, because §4 says nobody has a screen open during
> play. Design the five things you scribble on paper first.

---

# 6 · Mostly new data, not new combat mechanics

```text
NEW CAMPAIGN DATA  →  EXISTING COMBAT INPUTS  →  SEALED RESOLVER  →  DELTAS + EVENTS
```

If a Persistence feature requires a *new* combat mechanic, stop and check whether
the feature is really Persistence's.

---
---

# 7 · HARM — injury, healing and scars

> The first real content in this module. Everything below is playable.

## 7.1 · The lifecycle

```text
WOUND            transient · numeric · resolved at the table          [B · 7]
   │
   │  the battle ends
   ▼
INJURY           persistent · has effects NOW · has a recovery clock
   │
   │  time + care
   ▼
RECOVERED  ─or─  SCAR            permanent · has effects forever
```

**Wounds are Combat's. Injuries and Scars are Persistence's.**

## 7.2 · Two axes, one lifecycle, different sources

```text
COMBAT   ── wounds ──▶  BODY injury  ──▶  BODY scar
STORY    ── events ──▶  MIND injury  ──▶  MIND scar
                  PERSISTENCE owns the lifecycle for both
```

BODY harm comes from **damage**. MIND harm comes from **what happened**, which is
not the same thing and is not measured in Wounds. A figure can walk off the field
untouched and ruined.

> **Both axes are now live *combat* channels too — SIGNED (William, 2026-07-28).** The
> seventh batch made Morale a **channel** with its own damage and its own **Nerve** save
> (A · II, B · 10), so BODY and MIND take harm *during* the fight, not only in aftermath.
> Persistence is unchanged: it still owns the lifecycle that turns a battle's Wounds and
> Morale into lasting Injuries and Scars. The third channel, **SOUL**, is **reserved and
> permanently blank** (A · II) — Persistence never reads or writes it; it is witnessed
> only where Body and Mind interact (the dying swing, the Protective break, Rally).

---

## 7.3 · The Aftermath — how harm is rolled

Both checks use the **same three-dice shape as a Nerve test** (B · 10). Nothing new
is learned.

### BODY — the Care check
**Every figure that ended the battle Knocked Out** rolls once. *(Dead is dead.
Figures still standing take no BODY harm.)*

```text
Roll 3 dice against the Caravan's CARE number.

  no surgeon, no wagon   6+
  a field surgeon        5+
  surgeon + facilities   4+

0 successes  →  DIED OF WOUNDS. He never woke up.
1–2          →  lives · roll on the injury table, +1 to the severity die
3            →  lives · roll on the injury table
```

Then roll **d6 for LOCATION** — or use the location the killing blow actually
struck, where anyone remembers — and **d6 on that location's table.**

```text
LOCATION   1 Head   2 Torso   3 Arm   4 Hand   5 Leg   6 Foot
```

### MIND — the Nerve check
Rolled **only if a trigger happened to that figure** (§7.6). Not tied to going down.

```text
Roll 3 dice against the figure's NERVE.

3 successes  →  he carries it. No injury.
0–2          →  MIND injury from the trigger table
```

*(Circles test too. Heroes do not break in combat; that is not the same as being
untouched by it.)*

---

## 7.4 · BODY injuries

`ACTIVE` = while unhealed. `RECOVERY` = periods of rest, **with care**.
`NEGLECT` = what it becomes if he keeps marching instead.

### 1 · HEAD

| d6 | Injury | Active | Recovery | Heals to | Neglected |
|---|---|---|---|---|---|
| 1 | **Split brow** | blood in the eyes — −1 die on ranged | 1 | `weathered` | `weathered` |
| 2 | **Broken nose** | −1 die on ranged | 1 | `weathered` | `crooked_nose` |
| 3 | **Cracked skull** | Nerve worsens by 1 | 3 | recovered | `rattled` |
| 4 | **Shattered jaw** | cannot speak — **a Sergeant cannot call Form Up**, a leader cannot Rally | 3 | recovered | `wired_jaw` |
| 5 | **Eye destroyed** | −2 dice on ranged, −1 die on melee | 2 | `one_eye` | `one_eye` |
| 6 | **Skull staved in** | −1 AP · Nerve worsens by 2 | 5 | `rattled` | **retired — he is not himself** |

### 2 · TORSO

| d6 | Injury | Active | Recovery | Heals to | Neglected |
|---|---|---|---|---|---|
| 1 | **Deep gash** | −1 die on melee | 1 | recovered | `knotted_scar` |
| 2 | **Cracked ribs** | −1 die on melee · cannot Sprint | 2 | recovered | `bad_ribs` |
| 3 | **Broken collarbone** | cannot use a shield or a two-handed packet | 3 | recovered | `dropped_shoulder` |
| 4 | **Bruised spine** | Move −2″ · cannot Brace | 3 | recovered | `stiff_back` |
| 5 | **Punctured lung** | Move halved · cannot Sprint · −1 Wound | 4 | `short_wind` | `short_wind` |
| 6 | **Gut wound** | −1 Wound · **roll Care again next period or die** | 5 | `iron_gut` | **dies** |

### 3 · ARM

| d6 | Injury | Active | Recovery | Heals to | Neglected |
|---|---|---|---|---|---|
| 1 | **Sprained elbow** | −1 die on melee | 1 | recovered | `weak_arm` |
| 2 | **Dislocated shoulder** | cannot use a two-handed packet | 2 | recovered | `loose_shoulder` |
| 3 | **Torn bicep** | −1 die on melee · cannot Shove | 3 | recovered | `weak_arm` |
| 4 | **Broken forearm** | that arm is useless — shield **or** weapon, not both | 3 | recovered | `crooked_arm` |
| 5 | **Nerve severed** | the arm will not grip | 4 | `dead_arm` | `dead_arm` |
| 6 | **Arm lost** | — | 4 | `one_arm` | **dies** |

### 4 · HAND

| d6 | Injury | Active | Recovery | Heals to | Neglected |
|---|---|---|---|---|---|
| 1 | **Sprained wrist** | −1 die on melee | 1 | recovered | `weak_grip` |
| 2 | **Crushed knuckles** | −1 die on melee | 2 | recovered | `weak_grip` |
| 3 | **Fingers broken** | cannot use a two-handed packet | 2 | recovered | `claw_hand` |
| 4 | **Tendon severed** | cannot use a shield | 4 | `claw_hand` | `claw_hand` |
| 5 | **Fingers lost** | −1 die on melee | 3 | `three_fingers` | `three_fingers` |
| 6 | **Hand lost** | — | 4 | `one_hand` | **dies** |

### 5 · LEG

| d6 | Injury | Active | Recovery | Heals to | Neglected |
|---|---|---|---|---|---|
| 1 | **Rolled ankle** | Move −1″ · cannot Sprint | 1 | recovered | `bad_ankle` |
| 2 | **Deep thigh cut** | Move −2″ | 1 | recovered | `bad_ankle` |
| 3 | **Broken ankle** | Move halved · cannot Sprint · cannot Form Up | 3 | `bad_ankle` | `short_stride` |
| 4 | **Knee wrecked** | Move halved · cannot Sprint | 4 | `short_stride` | `bad_knee` |
| 5 | **Torn achilles** | cannot Sprint · Move halved · cannot Form Up | 3 (never heals without care) | `short_stride` | `crippled_leg` |
| 6 | **Leg lost** | — | 5 | `peg_leg` | **dies** |

### 6 · FOOT

| d6 | Injury | Active | Recovery | Heals to | Neglected |
|---|---|---|---|---|---|
| 1 | **Bruised heel** | Move −1″ | 1 | recovered | recovered |
| 2 | **Broken toes** | Move −1″ · cannot Sprint | 2 | recovered | `bad_ankle` |
| 3 | **Arch destroyed** | Move −2″ · cannot Sprint | 3 | `short_stride` | `short_stride` |
| 4 | **Crushed foot** | Move halved · cannot Form Up | 4 | `short_stride` | `crippled_leg` |
| 5 | **Rot has set in** | Move halved · **roll Care again next period or lose the foot** | 4 | recovered | → *Foot lost* |
| 6 | **Foot lost** | — | 4 | `peg_leg` | **dies** |

---

## 7.5 · BODY scars

**A scar changes how a figure fights; it does not merely subtract.** Every entry
below takes something and gives something, because that is what surviving does.

| Scar | Effect |
|---|---|
| `weathered` | Cosmetic. He looks like he has been somewhere. **Meaning:** reads as a veteran. |
| `crooked_nose` | −1 die on ranged. **Meaning:** reads as a brawler. |
| `rattled` | Nerve worsens by 1. **But** he has already been through the worst thing he can imagine: **immune to Terror Effects.** |
| `wired_jaw` | Cannot call Form Up or Rally. He commands with his hands now — **may still initiate a Form Up if every joiner is within 2″** instead of 4″. |
| `one_eye` | −2 dice on ranged. **But** he stopped trying to shoot and learned the other side of the fight: **+1 die on melee in his front arc.** |
| `knotted_scar` | Armour worsens one step on the torso… **but** the scar tissue itself is thick: **first Wound each battle is ignored on a 6+.** |
| `bad_ribs` | Cannot Sprint. **+1 die while Braced** — he fights standing still now. |
| `dropped_shoulder` | Cannot use a two-handed packet. **+1 die with a shield equipped.** |
| `stiff_back` | Move −2″. Cannot Brace. **+1 die on every Counter he throws** — he stopped moving and started watching. |
| `short_wind` | Move −2″ · cannot Sprint · −1 Wound. He is old before his time. |
| `iron_gut` | −1 Wound permanently. **But** he has been opened up and lived: **ignores the first Nerve test of each battle.** |
| `weak_arm` | −1 die on melee. |
| `loose_shoulder` | Cannot use a two-handed packet. **May Shove for free once per battle** — he has learned exactly how to lean. |
| `crooked_arm` | Shield **or** weapon, never both. |
| `dead_arm` | One arm only. Cannot use two-handed or shield packets. **+1 die with a one-handed weapon** — everything he has goes into it. |
| `one_arm` | As `dead_arm`, and he cannot carry a second item at all. |
| `weak_grip` | −1 die on melee. Drops his weapon on a natural roll of all 1s. |
| `claw_hand` | Cannot use a shield. **+1 die on Reach packets** — the hand hooks the haft and never lets go. |
| `three_fingers` | −1 die on melee. |
| `one_hand` | One-handed packets only. **His Counter is never denied by facing** — flank and rear get answered like the front (B·8). Nothing to fumble with, and nothing gets behind him twice. |
| `bad_ankle` | Move −1″. Cannot Sprint on ground that is not flat and dry. |
| `short_stride` | Move −2″. **+1 die while Braced.** He stopped chasing people and learned to hold ground. |
| `bad_knee` | Move −2″ · cannot Sprint · cannot charge (§B · 3). **+1 die while Braced.** |
| `crippled_leg` | Move halved · cannot Sprint or Form Up. **He rides in the wagon.** Deployable only in defensive scenarios. |
| `peg_leg` | Move −3″ · cannot Sprint or charge. **Immune to Shove** — he is nailed to the ground and knows it. |

---

## 7.6 · MIND injuries — by what happened

MIND harm is **looked up, not rolled.** The event is owned by STORY (I · 9);
Persistence owns what it does to him.

| Trigger | MIND injury | Active | Recovery | Heals to | Neglected |
|---|---|---|---|---|---|
| An ally died in his hands | **Shaking** | −1 die on the first ACTION of each battle | 2 | recovered | `cannot_watch` |
| He answered a call for help and it was a trap | **Haunted** | cannot Rally others · Nerve worsens by 1 near the thing that fooled him | 2 | `never_again` | `no_quarter` |
| He was the only one who walked away | **Survivor** | Nerve worsens by 1 while no ally is within 3″ | 3 | `the_last_one` | `thousand_yard` |
| One of his own betrayed him | **Suspicious** | cannot be the target of a friendly Shield Intercept — he flinches away | 3 | `trusts_slowly` | `trusts_no_one` |
| He did a thing that cannot be undone | **Sick with it** | −1 die on melee against anything that resembles what he did it to | 3 | `no_quarter` | `butcher` |
| He saw something that should not exist | **Unmoored** | Nerve worsens by 1 · cannot Brace | 3 | `has_seen_worse` | `thousand_yard` |
| He was buried, trapped, or left for dead | **Closed in** | cannot enter enclosed terrain without passing a Nerve test | 2 | `the_dark` | `wont_go_in` |
| He broke and ran, and people died for it | **Ashamed** | Nerve worsens by 1 | 2 | `oathsick` | `craven` |

---

## 7.7 · MIND scars

Written as **Written Triggers** (A · XIV) wherever they fire on a condition —
structurally the same object as a grudge (I · 3). No new machinery.

| Scar | Effect |
|---|---|
| `never_again` | **Trigger:** a child — or a thing wearing a child — calls for help. **Effect:** he will not MOVE toward it, and treats it as hostile until something proves otherwise. |
| `the_last_one` | Nerve worsens by 1 while no ally is within 3″. **But** while he is the last of his Fireteam standing: **+1 die, and he may Brace for free** — 0 AP, and it does not end his activation. He has done this before. |
| `trusts_slowly` | Cannot be the target of a friendly Shield Intercept. **But** he covers his own line: **+1 die on any Shield Intercept he performs.** |
| `no_quarter` | **Trigger:** an enemy is Knocked Out within his reach. **Effect:** he finishes it, and he does not ask. Costs him nothing; costs the Caravan its Standing (STORY). |
| `butcher` | As `no_quarter`, and he will do it to a surrendering foe. **Meaning:** the Caravan is known for it now. |
| `has_seen_worse` | **Immune to Terror Effects.** Nerve worsens by 1 against ordinary men — he has stopped taking them seriously, and it gets him hurt. |
| `the_dark` | Cannot enter enclosed terrain without passing a Nerve test. **But** once inside and Braced: **+1 die.** Cornered is a place he understands. |
| `oathsick` | **He will not break again. Cannot go Broken.** But he cannot Disengage either — leaving a fight is the thing he cannot make himself do twice. |
| `cannot_watch` | **Trigger:** a friendly figure within 3″ goes Knocked Out. **Effect:** he must MOVE toward it on his next activation if he legally can. |
| `trusts_no_one` | Cannot be the target of a friendly Shield Intercept, and cannot be Rallied by another figure. **His armed WAIT does not expire when he activates** — he never stops watching, and he never has to pay to start again. |
| `thousand_yard` | −1 die on his first ACTION of each battle. **+1 die while no friendly is within 3″.** He works better alone now, which is the problem. |
| `wont_go_in` | Cannot enter enclosed terrain. Not for an objective, not for a friend, not at all. **+1 die in open ground.** |
| `craven` | Cannot charge (B · 3), and must Disengage from any fight he legally can while Shaken. **+2″ Move directly away from an enemy.** |
| `hollow` | See §7.7b. It does not fit in a row. |

### 7.7b · `hollow`

> **How a figure becomes hollow is not written here, and is not written anywhere
> in A–I.** What follows is the complete mechanical definition of the state. If a
> figure in your Caravan is hollow, you will be told that he is.

```text
hollow

  DEEPENS      Nerve worsens by 1 — and by 1 more at the end of every period
               he finishes with no friendly figure within 3″. It does not stop.

  EMPTY        Cannot form or hold a Bond. Not loyalty, not kinship, not a debt.
               Whatever he had lapses.

  CANNOT MEND  He may take no ACTION that repairs anything between people. He
               cannot Rally another figure, cannot tend the wounded, cannot make
               amends, cannot apologise, cannot reconcile. Nothing he does helps
               anyone.

  LASHES OUT   WRITTEN TRIGGER — when he is Wounded, or when any figure goes
               Knocked Out within 3″, he strikes the NEAREST figure, friend or
               foe. Once per occurrence; nothing buys it and nothing stops it.
               He is Wild in that moment (B · 10) and he does not choose it.
```

He is not a villain. He is a man nobody sat with.


---

## 7.8 · Care — what the Caravan is for

Recovery is never automatic. It needs **care**, and care is a Caravan ACTION (§3).
This is what gives the physical Caravan model real weight.

```text
BODY heals with CARE and TIME        →  surgeon · wagon · a warm place to lie down
MIND heals with RELATIONSHIPS        →  kin · a companion · someone who was there
```

**The asymmetry is deliberate.** A figure with no Bonds does not recover from what
he saw — his MIND injuries simply run to their `Neglected` column and stay there.
**Being alone is a mechanical disadvantage, not a mood.**

It also means the chaplain, the cook and the man's brother are worth as much roster
space as the surgeon. That is the intended shape.

## 7.9 · How harm reaches Combat without reopening it

```text
BODY scar  →  Move · dice · Wounds · Armour · facing · a packet he may not use
MIND scar  →  a Temperament procedure modifier, or a Written Trigger
```

The resolver never learns that the achilles tore in the mud outside Greyfen, or
that the thing in the barn was not a child. It reads a number and a clause.

---
---

# 8 · AFTER THE BATTLE — the procedure

> This is the loop the §7 tables hang inside. Without it you have harm rules and
> nothing that tells you who to roll for.

## 8.1 · The BATTLE RESULT — the analog tier

**This is the contract** (§5). The serialized form (§9.4) will encode *this*, not
the other way round. Five things, on paper, before anyone packs up:

```text
1. WHO WENT DOWN    every figure that ended the battle Knocked Out —
                    and where it hit, if anyone remembers
2. WHO DIED         killed outright on the field
3. WHAT IT COST     supplies spent · equipment lost, broken, or taken
4. DID YOU WIN      objectives held · taken · failed
5. WHAT HAPPENED    one line for each moment that mattered
```

Line 5 does double duty: it is the **MIND trigger feed** (§7.6) and it is
STORY's raw material (Document I). *"Bram carried Aldous out and Aldous died
anyway"* is one line, and it is both a mechanic and a story.

## 8.2 · The sequence

```text
1. WRITE THE BATTLE RESULT                                        (8.1)
2. AFTERMATH — Care check + injury roll, every figure on line 1   (7.3)
3. MIND CHECK — Nerve check, every figure a line 5 event hit      (7.3)
4. TEND — the Caravan spends its care                             (8.3)
5. ADVANCE THE CLOCK — one period passes                          (8.4)
6. WRITE IT DOWN — the Caravan sheet                              (9.2)
```

## 8.3 · TEND — care is finite, and that is the decision

Care is a Caravan ACTION (§3), and there is never enough of it.

```text
CARE CAPACITY — figures the Caravan may tend each period

  no surgeon             1
  a field surgeon        2
  surgeon + facilities   4
```

**Recovery only advances in a period the figure was tended.** An untended period
is not a slower period; it is not a period at all.

```text
UNTENDED  →  recovery counter does not tick
             once a figure has gone untended for as many periods as the
             injury's recovery cost, it converts to its NEGLECTED outcome
```

So a 1-period injury goes bad almost immediately if ignored, and a 4-period one
gives you time to get to it. The table scales itself.

> **You have four wounded and two hands.** That is the between-battle game: not
> *whether* people recover, but **who you choose.** The man you leave until next
> period is the man who ends up with the scar, and everyone at the table will know
> you chose him.

**MIND injuries are tended too** — but by a *person*, not the surgeon (§7.8). A
figure who spends the period beside him counts as tending him, and cannot tend
anyone else.

## 8.4 · The clock — placeholder

```text
ONE BATTLE = ONE PERIOD
```

A deliberate stub until the real clock lands (§9.3). It is enough to run a
campaign: injuries tick, neglect bites, scars accumulate. What it cannot yet do is
let time pass *without* a battle — no travel, no seasons, no waiting somewhere
safe to heal.

## 8.5 · What the app does with all this

Nothing above needs a screen. The app (§4) reads the sheet afterwards and keeps the
ledger: recovery counters, scar lists, who is fit, who is in the wagon, and the
history that STORY will want later.

**If the app is not open, the campaign still runs.** That is the test §8.1 exists
to pass.

---

# 9 · Open work

### 9.1 · Balance pass on §7
The tables are written and coherent; they are **not** costed. Scars that grant
`immune to Terror`, a **free Brace**, a **non-expiring WAIT**, or a **Counter that
ignores facing** need checking against `factions/sim/balance.py` before anyone
builds a veteran deliberately.

*(Four scars previously granted `+1 Reaction`. Rewritten 2026-07-27 when the
Reaction Resource was struck — `stiff_back`, `one_hand`, `the_last_one`,
`trusts_no_one`. Each still takes something and gives something; none of them has
been costed, and this pass still owes them a look.)*

### 9.2 · The QR payload schema
What is on the code, what is referenced, versioning. See the §4 constraint.

### 9.3 · The campaign clock
**Deliberately low-res for now.** §7 counts recovery in *periods*; a period is
currently "the gap between battles." When the clock opens: seasons, travel time,
and what rivals do while you are elsewhere. Time is already a Kernel Resource
(A · IV) and nothing spends it.

### 9.4 · The combat output schema
**The analog tier is written (§8.1).** What remains is serializing it — the JSON
form of the five lines, plus actor/target references on line 5 so STORY can key
events to figures rather than to prose.

### 9.5 · Advancement
Experience, what it buys, whether it can be lost — and how it interacts with scars.
A veteran should be a ledger of both.

### 9.6 · Ruin
What happens when the Caravan is destroyed. There is advancement and harm here, and
still no way to lose the whole thing.

### 9.7 · Whose persistence?
Do rival factions carry injuries and scars between sessions? A world where a beaten
warband is weaker next time is a very different game from one where it is not.

---

# 10 · Module contract status  (A · XVII)

```text
1. cites the Constitution and Dictionary          ✅
2. translates MOVE · ACTION · WAIT                ✅  §3 — and TEND (§8.3) is the
                                                     first real ACTION written
3. owns its Procedures                            ✅  HARM (§7) and AFTER THE
                                                     BATTLE (§8)
4. stores facts, computes judgments               ⚠  §8.1 is the analog record;
                                                     no serialization schema yet
5. reduces every mechanic to a primitive          ✅  §7.9 — every effect is a
                                                     State or Resource the
                                                     resolver already reads
```

**Four of five discharged. Persistence is a working module** — you can run a
campaign out of §7 and §8 with a pencil today. What is missing is storage, not
rules.
