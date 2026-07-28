# CUS — FIREARMS & RANGED WARFARE
### v0.6 · Combat Module extension · the universal firearm engine · signed 2026-07-28 (William)

> **What this is.** The ranged-warfare procedures — how a gun resolves, from a
> flintlock to an autogun. It is a **Combat Module extension**: it cites Document B
> and does not restate it. Every mechanic here reads or writes a Kernel primitive
> (Position · Force · State · Resource) and cites it.
>
> **One engine, any era.** The firearm engine is **setting-agnostic** — a
> muzzle-loading musket and a full-auto autogun run the **same math**. What changes
> between settings is the **content** (which weapons and factions exist), never the
> resolution. Fantasy fields blackpowder; the sci-fi setting fields autoguns; both
> read this one document. `→ G·one-engine-any-era`
>
> **Authority.** Where K conflicts with A (Kernel) or B (Combat), **they win.** K
> owns the ranged Procedures B delegates to it; it invents no primitive.
>
> **On "not."** A `→ G·<slug>` token means the obvious reading is wrong and
> [Document G](G_WHY_NOT.md) carries the argument.

```text
A gun is a Ranged PACKET (B·5). Everything below is that packet's fields, the
Procedures that read them, and the two Resource kinds (Charge/Strain) that pace it.
```

---

# 1 · A gun is a Ranged PACKET  `[resolves PACKET → Grade]`

No new verb, no shooting phase. A firearm is a **Ranged PACKET** resolved by ACTION
(A·III, B·5). Its name carries the theme; its fields carry the rules (Law 11).

```text
GUN PACKET = { range · dice · success · grades · effects · provokes:false ·
               not_in_contact · cost:{spend Charge | gain Strain} · tags }
```

- **`not_in_contact` by default** (B·8, the signed `ranged-in-melee` ruling): a gun
  turns **off** the instant an enemy base touches yours — you drop it and swing
  Fists. The geometry does the mode-switch; no rule fires. A weapon that *may* fire
  in contact (a flintlock pistol pressed to the chest, a wrist-bolter) is authored
  **without** the constraint, and that omission is a **priced** advantage.
- **`provokes: false` always** (B·9): a shot **never draws a Counter**, however close
  the shooter stands. Answering a bullet is not a thing Position permits.
- **Hybrid is the native case.** A figure carrying a gun *and* a blade is **Tool =
  Hybrid** (A·VII): it simply holds **two packets** — one Ranged, one Melee (or
  default Fists). Nothing switches modes but the geometry. This is the trench-fighter,
  the gunslinger, the bolter-and-chainsword. `→ G·hybrid-is-two-packets`

Line-of-sight and cover are **direct-fire** concerns (bullets), read as physical
geometry (Law 8): you must **see** what you shoot **at**, and cover raises the shot's
success number by 1 (harder). Indirect weapons (§5) waive line-of-sight.

---

# 2 · The gun grade ladder — SIGNED (William, 2026-07-28)

A shot is not "roll to wound." It **climbs a grade ladder whose rungs are different
effects** — you might be shooting to *pin*, to *wound*, or to *cripple* — and the dice
decide how high you climb (B·6, Model-2 discrete grades). The canonical firearm ladder:

```text
GRADE 1 → STUN / SUPPRESS     no wound — the agent is STOPPED (Stun) or shaken (Morale)
GRADE 2 → WOUND               1 Wound (armour saves)
GRADE 3 → CRIPPLE / KILL      2 Wounds · a lasting −Move Cripple · or ignore-Armour
```

- **The low rung is the thing a gun does that a sword cannot (§3)** — it stops or shakes
  the target without killing it, which is how a small elite survives an endless enemy:
  you cannot out-kill a faucet, so you **hold it** and buy time.
- Weapons **author their own ladders** (a sniper's ≠ a scattergun's). Grades stay
  **discrete** — Grade *N* resolves only its own line (A·VI). `→ G·grade-is-not-a-tier`
- **More dice = higher grade reached.** That is why the blast bands (§5) *feel* right —
  they set the dice by distance, so center-of-blast **cripples** and the rim only
  **rattles**, straight off this ladder.

---

# 3 · The low rung — Stun & Suppress  `[State · Mind]` — SIGNED (William, 2026-07-28)

Grade 1 doesn't wound — it *stops* or *shakes*. Two effects, two organs, and a weapon
authors which it deals (or both):

## STUN — the action economy  `[State: the flag]`
A grade-line **`Stun`** knocks the target **one step down the activation flag** (B·12):
ready → waiting, waiting → spent, recovers next activation. No new marker — it rides the
stoplight already on the base (J). **It works on the fearless** — a stun is a concussion,
not a fear, so it stops a mindless horde where Morale can't. This is what killed the old
"Pin" state: suppression *is* Stun, and it needs no bespoke hardware. `→ G·stun-rides-the-flag`

## SUPPRESS — the Mind channel  `[Morale via B·10]`
A grade-line **`1 Morale`** deals damage on the **Mind channel** (B·10): the target's
**Nerve** save resists it, and each unsaved point steps Steady → Shaken → Broken. Volume
of fire *breaks* men. Fearless targets (Spirit · Construct · Circles) are **immune** —
you cannot frighten what has no Mind.

```text
Want to STOP anything (incl. the fearless horde)  →  deal STUN     (the flag)
Want to BREAK men                                  →  deal 1 MORALE (the Mind channel, B·10)
```
*(The old "Pin as its own State" is struck — Stun covers the physical stop, Morale covers
the fear, and neither needs a new marker. See Document E, seventh batch.)*

---

# 4 · Spray — the chain  `[Position]` — SIGNED (William, 2026-07-28)

A rapid or spreading weapon (autogun, HMG, blunderbuss) **walks a burst through a
cluster.** It is the **ranged twin of Cleave** (the melee multi-hit, B·6).

```text
Fire the shot; then SPEND 1 CHARGE to hop to the NEAREST UNHIT ENEMY within 3" of the
last target and shoot it (a full roll). Repeat until Charge runs out or no target in
range. Enemies only (never friendlies); never re-hits a figure; needs line-of-sight
per hop; provokes:false.
```

- **Walk the blob.** The chain hops target-to-target across a packed mob until the
  magazine is dry. It **self-terminates** — a 3-Charge autogun sprays up to 3 bodies,
  then reloads — and it is **geometry-gated**: it only chains through a *cluster*. Hordes
  bunch → the gun mows them; spread-out elites → the chain dies at hop one. Position caps
  it, which is the Kernel's ethos (A·II). `→ G·spray-is-ranged-cleave`
- **Ammo is the limiter, not a die penalty.** Each hop is a *full* roll (no falloff) and
  costs **1 Charge** (§6). That ties the horde-sweeper straight to the reload economy —
  spray empties you in one burst, and each target's own grade roll already makes some
  suppressed and some killed, so no "−1 die walk" is needed.

---

# 5 · Blast & Scatter — indirect area fire  `[Position]` — SIGNED (William, 2026-07-28)

The one genuinely new **PACKET effect type** — and it is a **delivery method, not an
effect.** A `blast` drops a **template** on a point and resolves against everyone under
it; *what* it delivers is your existing grade-line vocabulary, so the whole grenade
family is one mechanic:
```text
frag     → Wounds      gas / screamer → Morale     flashbang → Stun
krak     → ignore-Armour                concussion → Knockdown
```
Every knob is a **named packet field** (Law 15) — frag, mortar, powder-bomb and gas are
all *data*, not separate rules.

## The parameters
```text
los    : bool   need line of sight to the point?   bullet true · grenade FALSE
path   : bool   need a clear trajectory?           arcs OVER cover, blocked by solid/ceiling
                → "throw over a wall, not through one" = los:false · path:true
bands  : per-ring WIDTH in inches for the 3 / 2 / 1-dice rings.
                default [1,1,1] = a 1"/2"/3" template · [0,1,1] = no lethal core (a wide
                weak cloud) · [2,2,2] = a fat artillery footprint
dice   : 3 / 2 / 1 by ring   → each figure under the template rolls its ring's dice as
                its OWN attack (→ its own Grade → armour saves as normal). center reaches
                Grade 3 (cripple/kill), the rim only Grade 1 (a graze). provokes:false.
```
Center shreds, edge rattles — straight off the grade ladder (§2), no bonus math.

## Indirect + friendly fire — SIGNED
Blast is **indirect** (`los:false`): you lob to a point, you don't have to *see* it —
that's the whole point of an arcing weapon. **Friendly fire is ON**: a template that
lands on your own men hits them too. Both are locked; blind fire is dangerous to call.
`→ G·a-grenade-is-indirect`

## Scatter — did it land where you aimed?  `[the arrow-dice]`
Because it's blind, the shot **drifts** before the template is laid — a **random walk**
you resolve with **arrow-dice** (d6s marked with directions):
```text
1. Shot tier (Quick / Normal / Precise — from the shot ladder, B·9b, set by prior
   movement) gives a BASELINE drift:   Quick 3 · Normal 2 · Precise 1 step
2. Roll the weapon's accuracy pool (~3–4 dice) vs its success number.
   EACH MISS adds one more drift step.
3. Total = baseline + misses. Move the template that many 1" steps, each a freshly
   rolled arrow direction → random walk (clusters near the point, occasionally wild).
```
A set-up crew that rolls well barely moves; a rushed crew rolling badly walks the shell
into its own line. **Aim is not a new mechanic — it IS the Quick/Normal/Precise shot
ladder** (B·9b), and `accuracy` is just a packet field. `→ G·scatter-is-a-random-walk`

---

# 6 · Charge — the finite Resource (skinned Ammo)  `[Resource: Charge]` — SIGNED (William, 2026-07-28)

A ballistic weapon `spends Charge` per shot — the **finite** Resource kind (A·IV, 🟡).
The engine only knows *Charge*; the sci-fi card **skins it "Ammo,"** a fantasy card
"Arrows." Charge is the limiter that makes a firing line a **logistics problem** — and
the terror it exists to create is **the whole squad running dry at once.**

```text
CHARGE is a 0–3 pool (rifle 3 · LMG 2/brutal · pistol 3–4). Each SHOT spends 1; a SPRAY
spends 1 per target (§4); an OVERCHARGE spends 1 more for +dice/ignore-Armour (§8). So a
3-Charge weapon = up to 3 targets before it runs dry — "how much you bring at once."
CHARGE EMPTY → RESTORE (reload) = one activation you do NOT shoot = the CARD GOES DOWN.
```
Reload is the **card-down** already in the hand-management system (J·3): a gun restoring
Charge is a figure that spent its activation, offline until it comes back up.

**The synchronized-empty failure — the point of the whole system.** A squad that all
fires every turn empties on the **same round** → the whole line reloads together → it
gets overrun. Charge is **deterministic** precisely so this is a real, *avoidable*
catastrophe. The skill is **staggering** the restores: top up early behind cover, offset
the dry-turns, keep one gun in reserve. `→ G·a-resource-kind-is-not-a-mechanic`

## Blackpowder — the muzzle-loader
A muzzle-loader is a **Charge pool of one**: single-shot. Fire it and it is empty until
you spend an activation to restore it (the same card-down). "One shot, then draw steel"
is a `reloading` **Written Trigger** on the packet (A·XIV).

## Misfire
Blackpowder fouls: a weapon tagged `misfire` rolls a risk on firing, and on the bad
result the shot **fails and the weapon locks** (card-down to clear) — the powder-era
counterpart of an overheat (§7). A twist on a Charge weapon, not a new resource.

---

# 7 · Strain — the accumulating Resource (skinned Heat)  `[Resource: Strain]` — SIGNED (William, 2026-07-28)

An energy weapon never runs **dry** — it `gains Strain`, the **accumulating** Resource
kind (A·IV, 🔴). The engine knows *Strain*; the sci-fi card **skins it "Heat,"** a
fantasy card "arcane instability." Strain is the discipline limiter, the opposite
pressure to Charge.

```text
STRAIN is a 0–3 pool. A shot adds 1, 2, or 3 (normal fire little; a pushed / overcharged
/ sprayed shot a lot). STRAIN VENTS 1 each turn you do NOT push.
Hit 3 → it POPS. Roll VENT vs BLOW-UP (skin: OVERHEAT):
   • VENT (violent but safe): the weapon locks a beat (card-down); Strain resets to 0.
   • BLOW-UP ("gets hot"): a Wound to the BEARER (armour saves) — a Persistence/Doc H
     scar hook: your own gun can maim you.
An OVERCHARGE (§8) always pushes to the pop and forces the roll — the plasma gamble.
```

**The interlock.** Charge pressures you on **logistics** (empty = helpless); Strain
pressures you on **discipline** (greedy = lock / burn). A mixed fireteam **self-staggers**:
the plasma gunner covers the lane while the riflemen restore Charge; the riflemen cover
while he vents Strain. The squad rhythm *emerges* from two opposite Resource kinds,
unscripted.

---

# 8 · Overcharge — spend the Resource for a bigger shot  `[Resource]` — SIGNED (William, 2026-07-28)

A universal lever tying the Resource kinds to the grade ladder. On firing you may **Overcharge**:

```text
OVERCHARGE → +1 die  OR  ignore-Armour on this shot,  and in exchange:
   Charge weapon → spend an EXTRA Charge (dry sooner)
   Strain weapon → gain EXTRA Strain (closer to the cap / gets-hot)
   muzzle-loader → raise the misfire risk (an overcharged powder load)
```

Overcharge is how you punch a big one through armour *now* and pay for it a turn later —
the risk/reward that makes Charge and Strain **decisions**, not just bookkeeping. Authored
weapons may cap or forbid it.

---

# 9 · Evasion — an `unpierceable` save  `[State]` — SIGNED (William, 2026-07-28)

Some figures are simply **hard to kill at range** (the sharpshooter faction's signature,
M). This is **not a new save** — it is the existing armour save carrying the
**`unpierceable`** tag (B·7): a save that **`ignore Armour` cannot bypass.** Against a
bolter, a blast, anything armour-piercing, the figure rolls its save anyway.

```text
EVASION  = an unpierceable save flavoured DODGE  (the agile / sneaky boys)
BULWARK  = an unpierceable save flavoured SHIELD (the heavy tanks AP can't crack)
```

One save, one tag (Law 15), two skins — the classic invuln-save pattern, no new
resolution step. It is the counter to the `ignore-Armour` meta: you cannot **out-gun** an
`unpierceable` figure, you have to **corner** it — deny the geometry, which is Position
doing the capping again (A·II). `→ G·unpierceable-is-a-tag`

---

# 10 · Reactions are facedown cards  `[WAIT]` — (recap of B·9b, J·3)

Reaction fire needs no new machinery: it is a **WAIT**, shown as a **facedown card at
the model** (J·3, the WAIT trap). On your activation you arm Overwatch (1 AP, B·9b);
the card goes face-down; when an enemy enters the lane you **flip it and resolve one
shot** — exhaustible (one shot, then spent), its quality set by the **shot ladder**
(what the shooter did before it waited). No pool, no token — the card **is** the
reaction. A held gun-line covering corridors is Overwatch, and the wave advances *into*
it. `→ G·overwatch-is-not-free`

---

# 11 · Setting expressions — one engine, two eras

The rules above never change. The **content** does. Every mechanic has a blackpowder
face and a sci-fi face:

```text
KERNEL NOUN       SCI-FI skin (autogun era)     FANTASY skin (blackpowder era)
Charge 🟡         AMMO / magazine               arrows · powder & shot (single-shot)
Strain 🔴         HEAT / reactor overload       arcane instability · fouling / MISFIRE
── procedures (same math either era) ──
spray/chain       autogun · HMG                 BLUNDERBUSS / scattergun (short spread)
blast+scatter     frag · mortar · shell         POWDER BOMB · grenado · hand-mortar · bombard
volley            suppressing fire              "GIVE FIRE!" — a rank volley (Form Up, B·11)
ignore-Armour     bolter                        the musket that punched plate off the field
point-blank       pistol in the scrum           flintlock (drop not_in_contact, priced)
overcharge        overcharged plasma cell       double-shotted / heavy powder load
```
The engine authors in the noun (`spend 2 Charge`, `gain 1 Strain`); the setting does the
one final conversion for the card ("2 Ammo", "reactor at 3").

## Worked example packets
```text
# Blackpowder (fantasy)
matchlock_musket   : range 18 · 2d · 5+ · grades[1:Suppress · 2:1W ignore-Armour] ·
                     not_in_contact · single-shot · misfire · slow to reload
flintlock_pistol   : range 6  · 2d · 4+ · grades[1:Suppress · 2:1W] · single-shot ·
                     FIRES IN CONTACT (no not_in_contact — priced)
blunderbuss        : range 6  · 3d · 4+ · SPRAY · single-shot · misfire
powder_bomb        : range 6(thrown) · BLAST 2/1/0 · SCATTER · single-use

# Sci-fi (separate setting, Document M) — authored in nouns; card skins Charge="Ammo", Strain="Heat"
autogun            : range 24 · 3d · 4+ · grades[1:Suppress · 2:1W · 3:2W] · SPRAY ·
                     Charge 3 · overcharge
heavy_bolter       : range 30 · 4d · 4+ · ignore-Armour · SPRAY · Charge 2 · overcharge
plasma_gun         : range 24 · 3d · 4+ · ignore-Armour · gain Strain · gets-hot · overcharge
frag_grenade       : range 8(thrown) · BLAST 2/1/0 · SCATTER · Charge 2 (carried)
```
These are illustrative shapes, not tuned prices — the pricer (`factions/sim`) sets the
numbers.

---

# 12 · What this extension owes the Kernel

```text
It OWNS       the ranged Procedures B delegates: the gun ladder, Stun, Suppress (Morale),
             Spray, Blast, Scatter, Charge/reload, Misfire, Strain, Overcharge, Evasion/
             Bulwark. It owns no primitive and no verb — Charge/Strain are Kernel Resources.
It READS/WRITES  Position (range · lanes · blast · spray hops · scatter), State (flag/Stun ·
             reloading · misfire · wounds · Morale), Resource (Charge · Strain · Agency).
It CITES     A·III (verbs) · A·VI (grades) · A·VII (Tool/Hybrid) · B·5 (PACKET) ·
             B·6 (Cleave) · B·8 (not_in_contact/facing) · B·9/9b (Counter/Overwatch) ·
             B·10 (Nerve) · B·11 (Form Up) · J (Component Layer, the trackers).
It MUST NOT  fork a mechanic, add a verb, or let a firearm draw a Counter.
```

A firearm is a Ranged PACKET with two limiters and a grade ladder. Everything else on
this page is a Procedure that reads one of those, or a skin the setting hangs on it.
