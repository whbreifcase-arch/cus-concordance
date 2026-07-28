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
GRADE 1 → SUPPRESS / PIN      no wound — the target is STOPPED, not killed
GRADE 2 → WOUND               1 Wound (armour saves)
GRADE 3 → CRIPPLE / KILL      2 Wounds · or a lasting −Move Cripple · or ignore-Armour
```

- **Suppress/Pin is the load-bearing low rung** — the thing a gun does that a sword
  cannot (§3). It is how a small elite survives an endless enemy: you cannot out-kill
  a faucet, so you **pin** it and hold ground.
- Weapons **author their own ladders** (a sniper's ≠ a scattergun's); Suppress is the
  common floor. Grades stay **discrete** — Grade *N* resolves only its own line
  (A·VI). `→ G·grade-is-not-a-tier`
- **More dice = higher grade reached.** This is why the two geometry rules below
  (blast bands, spray falloff) *feel* right: they add or subtract **dice**, which
  moves the whole shot up or down the ladder — center-of-blast **cripples**, the rim
  only **rattles**.

---

# 3 · Pin & Suppress — two reads of Grade 1  `[State · Temperament]`

Grade 1 stops the target. *How* it stops depends on whether the target can feel fear.

## PIN — physical, works on the fearless  `[State]` — SIGNED (William, 2026-07-28)
A **Pinned** figure loses 1 AP / cannot advance toward the shooter on its next
activation — the weight of fire physically stops the rush. Pin works on **fearless**
targets (Spirit · Construct · the Ravenous) that no morale rule touches. It is the
crowd-control lever: pin the lane, hold the line.

**Group-level for hordes — SIGNED.** A Pin applied to a spawn-blob/unit pins the
**whole unit at once**, marked by **one shared token**, never per-model. A horde is
many cheap models; a token per body is exactly the pile-up the Component Law forbids
(J · Principle 3). You suppress a *mob*, not individuals. `→ G·pin-is-per-mob`

## SUPPRESS — morale, breaks men  `[State via B·10]`
Against **breakable** troops (Man · Beast Squares), Grade 1 **also feeds the existing
Nerve/morale track** (Steady → Shaken → Broken, B·10) — volume of fire *breaks* men.
No new morale system: gunfire is simply another shock the Nerve roll already handles.

```text
FEARLESS target  → PIN   (physical State; the horde control lever)
BREAKABLE target → PIN + a Nerve shock (B·10); sustained fire can Break them
```

---

# 4 · Spray — the chain  `[Position]` — SIGNED (William, 2026-07-28)

A rapid or spreading weapon (autogun, HMG, blunderbuss) **walks a burst through a
cluster.** It is the **ranged twin of Cleave** (the melee multi-hit, B·6).

```text
Fire the shot; then make a FOLLOW-UP shot at the NEAREST UNHIT ENEMY within 3" of the
LAST target hit, at −1 die. Repeat: each hop −1 die, until dice < 1 or no target in
range. Enemies only (never friendlies); never re-hits a figure; needs line-of-sight
per hop; provokes:false.
```

- **Walk the blob.** The chain hops target-to-target across a packed mob, petering out
  as the dice run down. It **self-terminates** and is **geometry-gated** — it only
  chains through a *cluster*. Hordes bunch → the gun mows them; spread-out elites → the
  chain dies at hop one. Position caps it, which is the Kernel's ethos: depth from
  Position, not a flat modifier (A·II). `→ G·spray-is-ranged-cleave`
- **Dice do triple duty.** Base dice = accuracy **and** chain length **and** severity:
  the first target eats full dice (climbs to *cripple*), each −1-die hop reaches a
  *lower* grade, so the far end of the burst is **suppressed/winged**, not killed. One
  number tells the whole story of a burst.
- **Spray costs extra** (§6, §7) — each hop spends more Charge (or builds more Strain),
  so the horde-sweeper empties you faster, which is what keeps it honest.

---

# 5 · Blast & Scatter — indirect area fire  `[Position]` — SIGNED (William, 2026-07-28)

The one genuinely new **PACKET effect type**: a `blast` drops a **template** on a
target point, and distance from center writes bonus dice. Grenades, powder bombs,
mortars, shells.

## The template — concentric bands
```text
BLAST bands, measured from where it lands:
  inner  1" band → +2 dice   (hottest — ground zero)
  middle 2" band → +1 die
  outer  3" band → +0 (base dice)
Each figure under the template is its OWN attack roll (base + band dice) → its own
Grade → armour saves as normal (or ignore-Armour if authored). provokes:false.
```
Center-of-blast climbs to **cripple/kill**; the rim only reaches **suppress/knockdown**.
The template shreds the middle and rattles the edge, straight out of the grade ladder
(§2). Band dice are tunable per weapon.

## Indirect — NO line-of-sight — SIGNED
**Blast is indirect fire.** You target a **point within range**; you do **not** need
to see it. That is the whole point of a thrown or arcing weapon — a grenade goes *over*
the wall, a mortar *over* the ruin. Direct line-of-sight stays on **bullets** (§1);
area weapons waive it. `→ G·a-grenade-is-indirect`

## Scatter — did it land where you aimed?
Because it is indirect, the shot **drifts** before the template is laid. Scatter reuses
the **shot ladder** (B·9b) so aim still matters:

```text
Roll SCATTER: N one-inch steps, each in a rolled direction (a d6 as a 6-point clock).
The last step is the landing point.
  aimed / set (Precise, held ground) → 1 step   (min 1 — always some drift)
  normal move to the shot            → 2 steps   ("twice is normal")
  rushed / snap / max-range barrage  → up to 6 steps
```
A set gun-line mortar scatters little; a snap-lobbed grenade or a long barrage scatters
far. **Friendly fire is ON** — a scattered template that lands on your own men hits
them too. That is a feature, not a bug: indirect fire is dangerous to call. Minimum 1
step, so even a perfect shot keeps a little pucker.

---

# 6 · Charge — the finite Resource (skinned Ammo)  `[Resource: Charge]` — SIGNED (William, 2026-07-28)

A ballistic weapon `spends Charge` per shot — the **finite** Resource kind (A·IV, 🟡).
The engine only knows *Charge*; the sci-fi card **skins it "Ammo,"** a fantasy card
"Arrows." Charge is the limiter that makes a firing line a **logistics problem** — and
the terror it exists to create is **the whole squad running dry at once.**

```text
A magazine = a Charge pool of a few shots (rifle ~3 · LMG ~2/brutal · pistol ~4).
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
Normal fire is free. PUSHING the weapon (Overcharge §8, rapid fire, Spray) → gain Strain.
Strain VENTS 1 each turn you do NOT push.
Hit the Strain cap → the authored consequence fires (skin: OVERHEAT):
   • the weapon LOCKS (a cool-down, card-down to clear), and
   • for the volatile ones (plasma) it "GETS HOT" — a Wound to the BEARER (armour
     saves). A scar hook into Persistence (Doc H): your own gun can maim you.
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

# 9 · Evasion — the dodge save  `[State]` — SIGNED (William, 2026-07-28)

Some figures are simply **hard to hit** (the sharpshooter faction's signature, M). This
is the one genuinely new **resolution step** the ranged game adds.

```text
A figure with EVASION rolls a DODGE save die (e.g. 5+ · 6+; a Stealth variant is better).
The dodge works even against ignore-Armour and BLAST — it is the only defense that
beats armour-piercing.
```

- **Roll the BETTER of dodge or armour, never both** — the dodge is a *primary* save,
  not a stacked second one, or a dodging figure in cover becomes unkillable.
- Evasion makes its owner the **"you can't out-gun me, you have to corner me"** archetype
  — the counter to the `ignore-Armour` meta. Cornering (denying the escape geometry) is
  the answer, which is Position doing the capping again. `→ G·evasion-is-a-dodge`

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
It OWNS       the ranged Procedures B delegates: the gun ladder, Pin, Spray, Blast,
             Scatter, Charge/reload, Misfire, Strain, Overcharge, Evasion. It owns no
             primitive and invents no verb — Charge and Strain are Kernel Resources (A·IV).
It READS/WRITES  Position (range · lanes · blast · spray hops · scatter), State (Pin ·
             reloading · misfire · wounds), Resource (Charge · Strain · Agency).
It CITES     A·III (verbs) · A·VI (grades) · A·VII (Tool/Hybrid) · B·5 (PACKET) ·
             B·6 (Cleave) · B·8 (not_in_contact/facing) · B·9/9b (Counter/Overwatch) ·
             B·10 (Nerve) · B·11 (Form Up) · J (Component Layer, the trackers).
It MUST NOT  fork a mechanic, add a verb, or let a firearm draw a Counter.
```

A firearm is a Ranged PACKET with two limiters and a grade ladder. Everything else on
this page is a Procedure that reads one of those, or a skin the setting hangs on it.
