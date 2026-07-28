# CUS — THE ARCHETYPE REFERENCE
### v0.6 · the frame spine · Presentation-layer content, not constitution · 2026-07-28

> **What this is.** Every **Frame** — the base stat-line an agent is built on. An
> **Archetype** is not a costume, it is a **function**: `Archetype = Role × Tool ×
> signature` (A·VIII). So this isn't an infinite list — it's the Role × Tool grid plus
> the recognizable *signature knob* each cell leans on. **Factions are these frames with
> named knobs turned** — clear, never hidden (Law 15: a specialty is a named field, not a
> buried buff).
>
> **This is content, not law.** Archetypes live at the Presentation layer (A·VIII, A·IX);
> where they meet a rule, A–N win. **All numbers here are un-tuned baselines** — the
> pricer (`factions/sim`) sets the finals; these just say what *kind* of thing each frame
> is.
>
> **The frame is the mini's *configuration*, not its state.** Move · Armour · Wounds ·
> Nerve · Tool · Role · signature — what the unit *is.* Runtime state lives on the model
> (flags) and the campaign in the app (J).

**Legend.** Armour / Nerve tiers: `— None · Lt Light 6+ · Md Medium 5+ · Hv Heavy 4+ ·
imm immune (fearless / Circle)`. Move in inches (default 6). W = Wounds. AP = 3 for all.

---

# 1 · RANGED — Pressure & Anchor shooters

```text
FRAME          ROLE      TEMP       MOVE ARM  W  NERVE  SIGNATURE (the knob)
Rifleman       Pressure  Resolute    6   Lt   1  Lt     Charge — balanced range/dice; the gunline floor
Marksman       Pressure  Cowardly    6   Lt   1  Md     precision — low success#, long range, ignore-Armour
Heavy Gunner   Anchor    Resolute    5   Md   2  Md     Spray + high Charge — volume; holds a lane
Grenadier      Pressure  Aggressive  6   Lt   1  Lt     Blast — indirect template + scatter; clears clusters
Piercer        Pressure  Resolute    5   Lt   1  Lt     ignore-Armour + single-Charge (slow) — kills the tank
Artillery      Anchor    Resolute    4   —    2  Md     indirect Blast, long, no-LoS — static; a Large base
```

# 2 · MELEE — Pressure

```text
FRAME          ROLE      TEMP        MOVE ARM  W  NERVE  SIGNATURE
Warrior        Pressure  Aggressive   6   Md   2  Lt     Mob — weight of numbers; the melee floor
Berserker      Pressure  Ravenous     7   Lt   2  imm    'Ere-we-go — wounded → angrier (Written Trigger); fearless
Assassin       Pressure  Cowardly     8   Lt   1  Md     Fast + backstab (provokes:false) + armour that survives the lane
Cavalry        Pressure  Aggressive   9   Md   2  Md     Impact + the plow (§4) — mounted, elongated base, one class larger
```

# 3 · MELEE — Anchor

```text
FRAME          ROLE      TEMP        MOVE ARM  W  NERVE  SIGNATURE
Spearman       Anchor    Resolute     6   Md   1  Md     Reach 2" + Brace — holds ground, breaks a charge
Bulwark        Anchor    Resolute     5   Hv   2  Hv     Heavy + unpierceable — the wall AP can't crack
```

# 4 · HYBRID — gun & blade

```text
FRAME          ROLE      TEMP        MOVE ARM  W  NERVE  SIGNATURE
Skirmisher     Pressure  Cowardly     7   Lt   1  Lt     two packets + Fire-and-Fade — shoot, then reposition
Trench-fighter Pressure  Aggressive   6   Md   2  Md     point-blank pistol (drops not_in_contact) + blade
```

# 5 · UTILITY — casters, faith, support

```text
FRAME          ROLE      TEMP        MOVE ARM  W  NERVE  SIGNATURE
Wizard         Utility   Resolute     6   —    1  Md     CHARGE — prepared slots: control, bolts, buffs (disciplined)
Sorcerer       Utility   Aggressive   6   Lt   1  Lt     STRAIN — innate: builds → pops → wild surge (overcharge = gamble)
Druid          Utility   Protective   6   Lt   2  Md     summon (`raise`) + shapeshift + area heal — nature's Utility
Priest         Anchor    Protective   6   Md   2  Hv     Rally + heal + Morale support — the recovery valve
Medic          Utility   Protective   6   Lt   2  Md     Care / stabilize — the Persistence hook (keeps veterans alive)
Warlock        Utility   Cowardly     6   —    1  Lt     curse / hex / Suppress — deals Morale and debuff at range
```

# 6 · COMMAND & the exceptional

```text
FRAME          ROLE      TEMP        MOVE ARM  W  NERVE  SIGNATURE
Leader         Utility   Resolute     6   Md   2  imm    Rally + Orders + command aura; a CIRCLE — breaks by story, not dice
Champion       Pressure  Resolute     6   Hv   3  imm    a CIRCLE that fights — signature weapon, answers every angle
Monster        Pressure  Ravenous     6   Md   3+ imm    size — the plow + high Wounds; a Large base; a Type interaction
```

---

# 7 · The isomorphic map — one function, three settings

The proof that an archetype is a **function, not a costume**: the frame above never
changes. Only the skin does. Read across a row — same job, three worlds.

| Function (frame) | 🐉 Fantasy | 🚀 Sci-fi | 🎖 Modern |
|---|---|---|---|
| **Rifleman** | Archer · Bowman | Trooper · Bolter-line | Rifleman · line infantry |
| **Marksman** | Hunter · Longbowman | Sniper · long-las | Sniper · DMR |
| **Heavy Gunner** | Handgunner · volley-crew | Heavy Bolter | Machine-gunner · LMG |
| **Grenadier** | Bombardier · Alchemist | Missile-launcher | Grenadier · under-barrel |
| **Piercer** | Arbalist · heavy crossbow | Lascannon · melta | AT-rifle · .50 cal |
| **Artillery** | Bombard · trebuchet | Basilisk · earthshaker | Mortar team · howitzer |
| **Warrior** | Warrior · man-at-arms | Assault trooper · Ork Boy | Shock-trooper · assault |
| **Berserker** | Berserker · barbarian | Khorne · Ork Nob | (rage-doctrine breacher) |
| **Assassin** | Assassin · rogue | Callidus · stealth-suit | Spec-ops · knife-work |
| **Cavalry** | Knight-mounted · lancer | Bike · jetbike | Technical · APC |
| **Spearman** | Spearman · pikeman | shield-drone line | Bayonet line · riot line |
| **Bulwark** | Knight · shield-wall | Terminator | Breacher · riot-shield |
| **Skirmisher** | Scout · outrider | kill-team trooper | Dragoon · recon |
| **Trench-fighter** | Landsknecht · pistolier | Marine Tactical | Trench-raider |
| **Wizard** | Wizard · magus | Sanctioned Psyker | Forward observer (finite fire missions) |
| **Sorcerer** | Sorcerer · warlock | Rogue Psyker | Overclocked / experimental-weapon operator |
| **Druid** | Druid · shaman | Bio-mancer · hive-mind | CBRN · combat engineer |
| **Priest** | Cleric · warpriest | Chaplain | Chaplain · morale officer |
| **Medic** | Healer · chirurgeon | Apothecary | Combat medic |
| **Warlock** | Warlock · hexer | rogue psyker (malefic) | EW · jammer · psy-ops |
| **Leader** | Captain · lord | Sergeant · Captain | Squad leader · officer |
| **Champion** | Hero · knight-errant | Captain · Chapter Master | (named operator / ace) |
| **Monster** | Troll · dragon · ogre | Dreadnought · Carnifex | Tank · mech · walker |

The two most telling rows: **Wizard vs Sorcerer** is `Charge vs Strain` — prepared slots
vs innate surge — the *exact same axis* as ballistic vs energy weapons (ammo vs heat),
one floor up into the arcane. And the **caster maps cleanly onto modern warfare** as the
*forward observer* / *EW operator*: "Utility that alters Force at range through a
resource" is a function every setting has, whether it calls it a spell or a fire mission.

---

# 8 · Factions = a frame + named knobs (clear, never hidden)

A faction unit is a frame with a **printed list** of turned knobs — you read exactly how
far each is turned, nothing buried:

```text
Marine Tactical  =  Trench-fighter  +  { Heavy armour · 2 Wounds · They-Know-No-Fear
                                         (Stun/Morale-immune) · bolter: Spray + ignore-Armour }
Ork Boy          =  Warrior         +  { 3 Wounds (no shrug) · Mob++ · dakka (Spray, high success#) }
Tau Fire Warrior =  Marksman        +  { Evasion (unpierceable) · Fast/jetpack · pulse: Strain, not Charge }
Guardsman        =  Rifleman        +  { Light · 1 Wound · Cowardly · cheap · Orders-eligible }
Tempest Wizard   =  Wizard          +  { Charge 3 · a control school · frail (None armour) }
Chaos Sorcerer   =  Sorcerer        +  { Strain · overcharge-happy · a mutation Written Trigger }
```

Every knob is a named field (Law 15). Anyone can look at the card and see the whole
truth of the unit — which is the entire *no-one-memorizes-anything* promise, carried all
the way up to army-building.

---

# 9 · What this reference owes the Kernel

```text
It OWNS       nothing but frames — Presentation content (A·VIII/IX). No primitive, no rule.
It USES       Role/Tool/Temperament (A·VII) · the base classes (B·1) · the K signatures
              (Charge/Strain/Spray/Blast/Evasion) · Circles & break-triggers (B·10).
It FEEDS      the faction rosters (M, factions/data) — each unit is a frame + knobs.
It MUST NOT   hide a knob. A specialty is a named field, or it does not exist.
```

Twenty-odd functions, three settings, one stat-spine. Build the frame once; the fantasy,
the far-future, and the trench all just turn its knobs.
