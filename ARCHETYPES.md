# CUS — THE ARCHETYPE REFERENCE
### v0.6 · the layered frame model · Presentation-layer content, not constitution · 2026-07-28 (rev 2)

> **What this is.** How an agent is built, in **layers that don't mix.** The first draft
> of this doc put chassis, frames, signatures, overlays and temperaments on one shelf and
> called them all "archetypes" — a clean-sounding list that quietly violated its own
> abstraction boundary. Rev 2 gives every layer exactly one job, so it reads like the
> Kernel instead of a troop roster. *(Rev 1 → this file's git history; the register of the
> dead keeps its name.)*
>
> **Content, not law.** Everything here is Presentation (A·VIII/IX); where it meets a rule,
> A–N win. **All numbers are un-tuned baselines** — the pricer sets finals.

```text
STATE          current Wounds · AP · Nerve · flags · Position          runtime (model + app)
UNIT PROFILE   the fully-resolved unit a card prints
   = CHASSIS + FRAME + SIGNATURE + TEMPERAMENT + OVERLAYS + FACTION KNOBS
      CHASSIS       the body — base shape/size · Move · Armour · Wounds · Creature Type
      FRAME         the job  — Role × Tool (one of nine)
      SIGNATURE     the identity — one recognizable decision loop
      TEMPERAMENT   fallback psychology — the signed five (A·VII), chosen independently
      DOCTRINE      tactical posture — Advance · Hold · Evade · Protect · Hunt (overridable by a Mission)
      OVERLAYS      modifiers, NOT archetypes — Mounted · Emplaced · Massive · Circle · Command · Heroic
      FACTION KNOBS explicit adds / overrides — named, never hidden (Law 15)
```

An **Archetype** is just **Frame + Signature.** Everything else is a different layer.

---

# 1 · The nine FRAMES — Role × Tool

Role = **Pressure · Anchor · Utility** (A·VII — *Pressure applies Force, Anchor prevents
it, Utility changes it*). Tool = **Melee · Ranged · Hybrid**. That is the whole space —
nine cells, and every recognizable archetype lives *beneath* one of them. Names are
placeholders; the structure is the point.

```text
             MELEE        RANGED         HYBRID
PRESSURE     Assault      Shooter        Raider
ANCHOR       Guard        Gunner         Sentinel
UTILITY      Warden       Controller     Operator
```

- **Pressure** frames *make* the opposition react · **Anchor** frames *deny* space and
  passage · **Utility** frames *change the conditions* of the fight.
- The frame owns **Role, Tool, and basic packet expectations** — nothing physical, no
  personality, no gear.

---

# 2 · SIGNATURES — the decision loops

A signature is **one recognizable repeated decision** a player makes with that unit. It
may bundle two tightly-coupled rules (`Reach + Brace`) *only if they form one loop.* The
signature is what makes a Marksman feel unlike a Grenadier though both are Shooters.

```text
MELEE loops        Mob · Fury · Backstab · Impact · Counter (duel) · Reach-Brace · Interpose
RANGED loops       Precision · Spray · Blast · Pierce · Indirect · Fire-and-Fade · Suppress
RESOURCE loops     Charge (channel) · Strain (overcharge)
SUPPORT loops      Rally · Care · Heal · Raise · Transform · Orders · Deploy · Protect
```

Signatures are **skin-agnostic** — the whole reason the isomorphic map (§7) works. "Blast"
is Blast whether it's a grenade, a fireball, or a mortar.

---

# 3 · ARCHETYPES = Frame + Signature

The recognizable troop-types, rebuilt *underneath* the nine cells — **no baked chassis, no
baked temperament.** That is what lets a *resolute* dwarven berserker and a *ravenous* ork
berserker both exist, and a Bulwark be plate-clad **or** a spectral guardian.

```text
PRESSURE × MELEE — Assault
   Warrior      = Assault + Mob            weight of numbers, the melee floor
   Berserker    = Assault + Fury           wounded → angrier (Written Trigger)
   Duelist      = Assault + Counter        turn every entry into a punish

PRESSURE × RANGED — Shooter
   Rifleman     = Shooter + Charge         disciplined ordinary output — no specialist exception
   Marksman     = Shooter + Precision      low success#, long, ignore-Armour — kills elites
   Grenadier    = Shooter + Blast          area, indirect, scatter
   Piercer      = Shooter + Pierce         ignore-Armour, slow — kills the tank

PRESSURE × HYBRID — Raider
   Skirmisher   = Raider + Fire-and-Fade   shoot, then reposition
   Breacher     = Raider + Point-Blank     pistol in the scrum (drops not_in_contact) + blade
   Assassin     = Raider + Backstab        reach the target, strike where it can't answer

ANCHOR × MELEE — Guard    (function: DENY PASSAGE / PROTECT SPACE — armour is chassis, not here)
   Spearman     = Guard + Reach-Brace      holds ground, breaks a charge
   Bulwark      = Guard + Interpose        redirects hits onto itself; the wall — plate OR agile OR spectral

ANCHOR × RANGED — Gunner
   Heavy Gunner = Gunner + Spray           volume; locks a lane
   Piercing Gun = Gunner + Pierce          the anti-armour emplacement

ANCHOR × HYBRID — Sentinel    (the cell the first draft missed — holds lane AND contact)
   Watchman     = Sentinel + Overwatch     the armed WAIT that punishes movement
   Phalanx      = Sentinel + Brace-and-Fire hold the front, fire from it
   Warder       = Sentinel + Intercept     answers both the shot and the charge

UTILITY × MELEE — Warden
   Priest       = Warden + Rally           restores Nerve / clears Morale conditions
   Medic        = Warden + Care            prevents death — the campaign-asset keeper (Doc H)
   Bodyguard    = Warden + Protect         stands between a charge and its target

UTILITY × RANGED — Controller
   Channeler    = Controller + Charge      prepared, disciplined power (fantasy: Wizard)
   Overcharger  = Controller + Strain      innate power that builds → pops → surges (fantasy: Sorcerer)
   Disruptor    = Controller + Suppress    deals Morale / debuff at range (fantasy: Hexer)

UTILITY × HYBRID — Operator
   Summoner     = Operator + Raise         puts new bodies on the board
   Commander    = Operator + Orders        composes Rally + Form Up + Mission
   Shifter      = Operator + Transform     changes its own (or an ally's) configuration
   Engineer     = Operator + Deploy        drops emplacements, cover, hazards
```

> **The Rally / Care / Heal split is explicit** (they were one blur before): **Rally**
> restores Nerve/Morale · **Care** prevents death and preserves the campaign asset (H) ·
> **Heal** restores Wounds *this battle.* A frame has one *primary* signature; a faction
> can bolt the others on as knobs.
>
> **"Druid" was three loops stapled together** by convention. Split: **Summoner** (Raise),
> **Shifter** (Transform), **Restorer** (Heal/area). A faction Archdruid holds all three as
> *named knobs* — but "Druid" is not a foundational function.

---

# 4 · CHASSIS — the body

The physical layer. Owns **base shape · size · Move · Armour · Wounds · Creature Type** —
and *nothing else.* A few classes (baselines, un-tuned):

```text
CHASSIS        SHAPE   SIZE    MOVE  ARM  W   CREATURE   note
Light Infantry Square  Small    6    Lt   1  Man        cheap line / skirmish body
Line Infantry  Square  Medium   6    Md   2  Man        the standard soldier
Heavy Infantry Square  Medium   5    Hv   2  Man        plate; slow
Beast          Square  Medium   8    Lt   2  Beast      fast, no ranged
Large          Square  Large    6    Md   3  varies     plows one class larger (B·1/§4)
Emplacement    Square  Large    0    —    2  Construct  static; crew-served
```

**AP is Agency by rank — SIGNED (William, 2026-07-28): `Square = 2 · Circle = 3`** (A·IV).
The base shape sets it — a ranked figure gets two acts, a golden-child Circle three. *(This
corrected a doc drift: "AP = 3 universal" had lost the split the faction data always used —
`max_ap = 2` on the rank and file. Ninth batch, Document E.)* **Nerve** (psychic armour) is
likewise a chassis/knob value, independent of physical Armour — which is what lets a
barefoot fanatic run Heavy Nerve and a plated knight run Light.

---

# 5 · OVERLAYS — modifiers, not archetypes

The thing the first draft got most wrong: **Cavalry, Artillery, Leader, Champion and
Monster are not peer archetypes.** They are *overlays* laid over any Frame + Signature +
Chassis. This is what un-strangles the faction system.

```text
OVERLAY     does                                          examples
Mounted     elongated base · +Move · plows a class larger  Cavalry = any Pressure archetype + Mounted
Emplaced    Move 0 · crew-served · long/indirect            Artillery = Gunner + Indirect + Emplaced
Massive     Large base · +Wounds · plows                    Monster = any archetype + Massive
Circle      faceless · Morale-immune · breaks by trigger    (the exceptional — hero/champion)
Command     Rally / Orders aura                             Leader = any archetype + Circle + Command
Heroic      signature weapon · answers every angle          Champion = any archetype + Circle + Heroic
```

So a **Leader** can be `Assault+Mob` (a warlord), `Gunner+Spray` (a gunline commander), or
`Controller+Charge` (a wizard-general). A **Monster** can be `Assault+Fury` (a troll),
`Gunner+Indirect` (a living artillery-beast), or `Guard+Interpose` (a giant guardian).
Nothing pre-decides that every Leader is Utility or every Monster is Pressure. `→ overlays,
not shelves`

---

# 6 · TEMPERAMENT vs DOCTRINE

**Temperament comes out of the frame.** It is the **signed five** (A·VII) — *Cowardly ·
Resolute · Aggressive · Protective · Ravenous* — the fallback psychology when no authored
instruction resolves behaviour. It is **chosen independently**, never welded to an
archetype. A Marksman is not "a Cowardly"; a *Resolute* Marksman who keeps his distance is
perfectly coherent.

The first draft leaked *tactical doctrine* into Temperament (Marksman/Assassin/Skirmisher
all "Cowardly" — really meaning "prefers distance, flanks, disengages"). Those are not
cowardice. **SIGNED (William, 2026-07-28):** a separate **DOCTRINE / posture** axis,
orthogonal to Temperament:

```text
TEMPERAMENT (psychology, the signed five)   Cowardly · Resolute · Aggressive · Protective · Ravenous
DOCTRINE    (tactical posture)              Advance · Hold · Evade · Protect · Hunt
```

Temperament is **who he is when cohesion fails** (commit, risk, break-behaviour); Doctrine
is **how he's inclined to fight** (position, engage-or-kite). Doctrine is a **default the
Mission can override** (A·XI) — it lives at the Combat/AI layer, **not** a fifth Kernel axis
(the four axes stay four). A *Resolute* Marksman on an *Evade* doctrine, or a *Cowardly*
Bulwark forced to *Hold* by Orders, both become expressible — and "Cowardly" stops secretly
meaning "shoots from range." `→ G·doctrine-is-not-temperament`

---

# 7 · The isomorphic map — from the FUNCTION, not the costume

The stronger proof (and the fix for the first draft's forced rows like "Druid → CBRN"):
start from the **neutral signature**, then map *that mechanic* across settings. Same loop,
three worlds.

| Function (signature) | 🐉 Fantasy | 🚀 Sci-fi | 🎖 Modern |
|---|---|---|---|
| **Charge** (channel) | Wizard | sanctioned psyker | forward observer (finite fire missions) |
| **Strain** (overcharge) | Sorcerer | unstable psyker | experimental / overclocked-weapon operator |
| **Suppress** (disrupt) | Hexer · witch | malefic psyker | EW · jammer · psy-ops |
| **Raise** | necromancer · shaman | drone-controller · biomancer | engineer deploying assets |
| **Transform** | shapeshifter | adaptive suit · morph | powered-exo mode |
| **Blast / Indirect** | bombard · alchemist | orbital · artillery | mortar · howitzer |
| **Pierce** | arbalist | lascannon · melta | AT-rifle · .50 |
| **Spray** | volley-crew · handgunner | heavy bolter | machine-gunner · LMG |
| **Backstab** | assassin · rogue | callidus · stealth-suit | spec-ops · knife-work |
| **Impact** (mounted) | lancer · knight | bike · jetbike | technical · APC |
| **Reach-Brace** | spearman · pikeman | shield-drone line | bayonet · riot line |
| **Fire-and-Fade** | scout · outrider | kill-team trooper | dragoon · recon |
| **Care** | chirurgeon | apothecary | combat medic |
| **Rally** | warpriest | chaplain | morale officer |

The two telling rows: **Charge vs Strain** is the *exact* axis as ballistic-vs-energy
weapons (ammo vs heat), one floor up into the arcane; and the caster maps to modern war as
the **forward observer / EW operator** — "Utility that alters Force at range through a
resource" is a function every setting has, whether it's a spell or a fire mission.

---

# 8 · A UNIT PROFILE — fully resolved, with sources

A card shows the *whole truth,* and every field is tagged with the layer it came from — so
you can see exactly which knob a faction turned and where:

```text
MARINE TACTICAL
   Frame        Pressure × Hybrid — Raider        [Frame]
   Signature    Point-Blank                        [Signature]
   Chassis      Heavy Infantry (Sq/Med · Mv5 · Hv · 2W · Man · AP2)   [Chassis]
   Temperament  Resolute                           [Temperament]
   Doctrine     Advance                            [Doctrine]
   Nerve        Heavy (immune to Stun & Morale)    [Faction: They-Know-No-Fear]
   bolter       Spray + ignore-Armour              [Faction]

ORK BOY
   Frame        Pressure × Melee — Assault         [Frame]
   Signature    Mob                                [Signature]
   Chassis      Line Infantry, but 3 Wounds        [Chassis + Faction override: W 2→3]
   Temperament  Aggressive                         [Temperament]
   Doctrine     Hunt                               [Doctrine]
   slugga       Spray, high success# (spray-and-pray)   [Faction]
```

**Deltas are visible as overrides** (Ork W `2→3`), and additions carry their source. That
is "no one memorizes anything" carried to the card: read the tags, you know the whole unit.

---

# 9 · What this reference owes the Kernel

```text
It OWNS       nothing but layered Presentation content (A·VIII/IX). No primitive, no rule.
It USES       Role/Tool (A·VII, as PRESSURE/Anchor/Utility) · the signed 5 Temperaments
              (A·VII) · AP=3 universal (A·IV) · base classes (B·1) · Circles (B·10) · the
              K signatures (Charge/Strain/Spray/Blast/Suppress) · Care (H).
It FEEDS      the faction rosters (M · factions/data) — each unit is Chassis + Frame +
              Signature + Temperament + Overlays + Knobs, fully resolved.
It MUST NOT   mix layers, bake temperament into a frame, or hide a knob.
```

Nine frames, a bag of signatures, a handful of chassis and overlays, five temperaments —
and every troop-type in every setting is a **resolved combination** of them, never a new
shelf. That is the difference between a clever list and the Kernel.
