# CUS FACTIONS — Templars vs Mordor · v0.6 build
### Two full factions, authored native to the v0.6 Kernel (A/B/C). 2026-07-24

> **Authority.** Everything here obeys `CUS_KERNEL_REBUILD/` (v0.6, CLOSED). No old
> vocabulary. Verbs = **MOVE · ACTION · WAIT**. Result = **Success Grade** (Model 2
> discrete — a Grade resolves ONLY its own line). Roles = **Pressure · Anchor ·
> Utility**. Tool = **Melee · Ranged · Hybrid**. Sizes = **Small · Medium · Large**.
> Temperaments = **Cowardly · Resolute · Aggressive · Protective · Ravenous**.
> PACKETs carry **neutral IDs**; classification lives in the `packet_index` sidecar.
> Traits are **referenced passive Definitions** (`trait_id`).

The two factions are deliberate opposites across every axis so the matchup teaches
the system:

| Axis | **Order of the Argent Templar** | **The Iron Horde of Mordor** |
|---|---|---|
| Fantasy | Holy heavy-knight order ("space marines") | Uruk-hai + Mordor orc swarm ("space orks") |
| Economy | Few, elite, expensive | Many, cheap, expendable |
| Force profile | **Anchor**-heavy; deny & endure, then execute | **Pressure**-heavy; overwhelm before they set |
| Armour | Heavy (4+) everywhere | Light/None; Uruks are the exception (Medium) |
| Tempo | Slow–Normal (they arrive in order) | Normal–Fast (they arrive first, and angry) |
| Temperament | Resolute / Protective (discipline, Zeal) | Aggressive / Ravenous / Cowardly (fury + chaff) |
| Morale | Barely tests (Zeal, high discipline) | Uruks hold; orcs shatter | 
| Creature Type | Man | Man (orc) + Beast (warg/troll) |
| Win condition | Survive the wave, counter-punch with the Grand Master | Break the line in the first two turns or lose |

---

# PART 1 — THE ORDER OF THE ARGENT TEMPLAR

*Sworn knights of a fading light. Few in number, unbreakable in the line. They do
not chase; they endure, and where they plant a banner, the ground does not move.*

Doctrine: **the Wall and the Sword.** Anchors hold the shieldline; the Grand Master
and Sword-Brothers convert the enemy's spent fury into executions. Nearly everything
is **Heavy armour** and **Resolute/Protective** — they win by not losing.

### Roster (9 definitions)

| # | Unit | Rank | Role | Tool | Temperament | Base | Wounds | Armour | Signature |
|---|---|---|---|---|---|---|---|---|---|
| T1 | **Grand Master Aldric** | III | Pressure | Melee | Resolute | Circle / Large | 3 | Heavy | Champion. Smite + Rally aura |
| T2 | **Templar Marshal** | II | Anchor | Melee | Protective | Circle / Medium | 3 | Heavy | Sergeant. Shield Wall command |
| T3 | **Battle-Chaplain** | II | Utility | Hybrid | Protective | Circle / Medium | 2 | Medium | Lay on Hands + Zeal (bless) |
| T4 | **Sword-Brother** | I | Pressure | Melee | Resolute | Square / Medium | 2 | Heavy | Greatsword, Cleave line |
| T5 | **Shield-Brother** | I | Anchor | Melee | Protective | Square / Medium | 2 | Heavy | Sword+Shield, Guard, Brace |
| T6 | **Halberdier** | I | Anchor | Melee | Resolute | Square / Medium | 2 | Heavy | Reach polearm |
| T7 | **Arbalest** | I | Ranged | Ranged | Resolute | Square / Medium | 2 | Medium | Heavy crossbow, armour-pierce |
| T8 | **Knight Lancer** | II | Pressure | Melee | Aggressive | Square / Medium (mounted) | 2 | Heavy | Elongated base; lance Impact |
| T9 | **Templar Sentinel** | I | Anchor | Melee | Resolute | Square / Large | 3 | Heavy | Consecrated construct-armour; Unstoppable-lite |

**Feel:** every Square is Heavy 4+ and hard to break. The faction has *one* ranged
answer (Arbalest), so it must close distance under fire and win in the grind. The
Lancer is the only Fast/aggressive piece — a scalpel, not the plan.

### Templar PACKETs — weapons (Grade ladders, Model 2 discrete)

Success number is the die value each die must meet. `G1/G2/G3` = successes needed.
Each Grade line is a **complete** result (discrete — no inheritance).

```
templar_longsword      Melee · Dice 3 · Success 3+ · reach:no
  G1 (1 succ) — 1 Wound
  G2 (2 succ) — 1 Wound + Guard
  G3 (3 succ) — 2 Wounds + Guard

templar_greatsword     Melee · Dice 3 · Success 4+ · two-handed
  G1 (1) — 1 Wound
  G2 (2) — 2 Wounds
  G3 (3) — 2 Wounds + Cleave         (carries to a second engaged body)

sword_and_shield       Melee · Dice 3 · Success 3+ · grants Guard on the profile
  G1 (1) — 1 Wound
  G2 (2) — 1 Wound + Push
  G3 (3) — 2 Wounds + Guard

consecrated_halberd    Melee · Dice 2 · Success 3+ · trait:reach
  G1 (1) — 1 Wound
  G2 (2) — 1 Wound + Push
  G3 (3) — 2 Wounds

heavy_arbalest         Ranged 24" · Dice 2 · Success 3+ · tag:armour_pierce, no_counter
  G1 (1) — 1 Wound (ignore Armour)
  G2 (2) — 2 Wounds (ignore Armour)

templar_lance          Melee · Dice 3 · Success 4+ · invoked by Impact, mounted
  G1 (1) — 1 Wound + Push
  G2 (2) — 2 Wounds + Push
  G3 (3) — 2 Wounds + Knockdown

sentinel_maul          Melee · Dice 2 · Success 4+ · slow, heavy
  G1 (1) — 1 Wound
  G2 (2) — 2 Wounds + Knockdown

grandmaster_blade      Melee · Dice 4 · Success 3+ · hero
  G1 (1) — 1 Wound
  G2 (2) — 2 Wounds + Guard
  G3 (3) — 2 Wounds + Cleave
  G4 (4) — 3 Wounds + Execute        (a KO'd/Hurt target is slain outright)
```

### Templar PACKETs — abilities

```
smite            ACTION · Self→Agent in 6" · Dice 3 · Success 4+ · (holy bolt)
  G1 (1) — 1 Wound (ignore Armour)
  G2 (2) — 1 Wound (ignore Armour) + target tests Nerve (Terror)
  G3 (3) — 2 Wounds (ignore Armour) + Terror

lay_on_hands     ACTION · Agent (ally) adjacent · no dice — restore 1 Wound (Fine←Hurt) / steady Nerve one step
shield_wall      WAIT · arms on "struck in melee" · while braced this figure & adjacent Shield-Brothers gain Guard; a Push against the wall fails
zeal_bless       ACTION · Area 3" allies · no dice — blessed allies re-read a failed Nerve test once this round; ignore first Shaken step
rally_command    ACTION · Area 6" allies · no dice — each Broken/Shaken ally steps UP one morale state (Sergeant/Champion only)
holy_banner      trait/aura — allies within 3" test Nerve with one extra die (4 dice, pick best 3)
```

### Templar traits used
`heavy_armour_profile` (Heavy save), `reach` (halberd), `mounted` (lancer, elongated
base, plows one class up via the lance), `consecrated` (Sentinel: only a wall stops
its Push — the Unstoppable-lite; a Large + partial-`unstoppable`), `zealous`
(fearless-lite: never steps below Shaken from a single shock).

---

# PART 2 — THE IRON HORDE OF MORDOR

*They do not march; they flood. Saruman's Uruk-hai are the anvil that walks — bred
without fear — and behind them the Mordor orcs come in a screaming, expendable tide,
with wargs at the flanks and something worse dragged up from the deep.*

Doctrine: **drown the line.** Cheap Pressure everywhere; get bodies into contact on
turn one, exploit the Counter economy by throwing chaff first, then land the Uruk
greatswords and the Troll where the wall has thinned. The horde's weakness is its
own nerve: Mordor orcs break the instant a friend falls.

### Roster (10 definitions)

| # | Unit | Rank | Role | Tool | Temperament | Base | Wounds | Armour | Signature |
|---|---|---|---|---|---|---|---|---|---|
| O1 | **Uruk Captain Gûlthak** | III | Pressure | Melee | Aggressive | Circle / Large | 3 | Medium | Champion. Savage command, Berserk |
| O2 | **Uruk Blackshield** | II | Anchor | Melee | Resolute | Circle / Medium | 3 | Medium | Sergeant. Holds the Uruk core |
| O3 | **Uruk Berserker** | I | Pressure | Melee | Aggressive | Square / Medium | 2 | Light | Two-hand cleaver, Frenzy |
| O4 | **Uruk Warrior** | I | Pressure | Melee | Resolute | Square / Medium | 2 | Medium | Scimitar+shield, the backbone |
| O5 | **Uruk Pikeman** | I | Anchor | Melee | Resolute | Square / Medium | 2 | Medium | Reach pike, Saruman's phalanx |
| O6 | **Uruk Crossbow** | I | Ranged | Ranged | Resolute | Square / Medium | 2 | Light | Heavy bolt |
| O7 | **Mordor Orc** | I | Pressure | Melee | Cowardly | Square / Small | 1 | Light | Chaff. Cheap, numerous, breaks |
| O8 | **Mordor Archer** | I | Ranged | Ranged | Cowardly | Square / Small | 1 | None | Volley, Skulk |
| O9 | **Warg Rider** | II | Pressure | Melee | Ravenous | Square / Medium (mounted) | 2 | Light | Beast; Fast; bite + rider |
| O10 | **Cave Troll** | III | Pressure | Melee | Ravenous | Circle / Large | 4 | Medium | Beast; **Unstoppable** (Large + trait); Wild when Broken |

**Feel:** far more bodies than the Templars, but fragile per-model except the Uruk
core and the Troll. Two ranged options (crossbow + archer volley). The plan is
**tempo and mass**; the failure mode is a bad-nerve cascade if the Uruks fall early.

### Mordor PACKETs — weapons (Grade ladders, discrete)

```
uruk_scimitar        Melee · Dice 3 · Success 4+
  G1 (1) — 1 Wound
  G2 (2) — 1 Wound + Push
  G3 (3) — 2 Wounds

uruk_cleaver         Melee · Dice 3 · Success 4+ · two-handed, Frenzy
  G1 (1) — 1 Wound
  G2 (2) — 2 Wounds
  G3 (3) — 2 Wounds + Cleave

uruk_pike            Melee · Dice 2 · Success 4+ · trait:reach
  G1 (1) — 1 Wound
  G2 (2) — 1 Wound + Push
  G3 (3) — 2 Wounds

uruk_crossbow        Ranged 24" · Dice 2 · Success 4+ · tag:no_counter
  G1 (1) — 1 Wound
  G2 (2) — 2 Wounds

orc_blade            Melee · Dice 2 · Success 4+   (chaff)
  G1 (1) — 1 Wound
  G2 (2) — 1 Wound + Push

orc_bow              Ranged 18" · Dice 2 · Success 5+ · tag:no_counter, volley
  G1 (1) — 1 Wound
  G2 (2) — 1 Wound + target tests Nerve

warg_bite            Melee · Dice 3 · Success 4+ · Beast, invoked by Impact
  G1 (1) — 1 Wound + Push
  G2 (2) — 2 Wounds
  G3 (3) — 2 Wounds + Knockdown

captain_cleaver      Melee · Dice 4 · Success 4+ · hero
  G1 (1) — 1 Wound
  G2 (2) — 2 Wounds
  G3 (3) — 2 Wounds + Cleave
  G4 (4) — 3 Wounds + Execute

troll_smash          Melee · Dice 3 · Success 4+ · Large, unstoppable, area-ish
  G1 (1) — 2 Wounds + Push
  G2 (2) — 2 Wounds + Knockdown
  G3 (3) — 3 Wounds + Knockdown (Cleave to a second body — it swings wide)
```

### Mordor PACKETs — abilities

```
savage_command   ACTION · Area 6" Uruk allies · no dice — target ally may make one extra Impact this activation
berserk_frenzy   WAIT/passive · when this figure Wounds, it may immediately ACTION again if a legal target is engaged (once per activation)
overrun          ACTION · Self · MOVE-aliased Sprint that resolves Impact on every body in the lane (Push/Indent/Crush)
skulk            WAIT · arms on "enemy approaches" · this figure may MOVE 3" away before engagement (chaff evasion)
bloodlust        trait/aura — Ravenous allies within 3" ignore their first Shaken step (they're too angry to notice)
wild_when_broken trait — on Broken this Beast turns Wild: attacks nearest figure friend or foe (Ravenous Rout)
```

### Mordor traits used
`reach` (pike), `mounted` (warg, elongated, plows one class up), `unstoppable`
(Troll: Large, only a wall stops its Push — the canonical "monstrous = Large +
trait"), `beast` (warg/troll — Creature Type Beast for morale/targeting),
`fearless_uruk` (Uruks never test below Shaken — Saruman bred the fear out),
`expendable` (Mordor orc: cheap, and its death triggers others' Nerve shock).

---

# PART 3 — SHARED SYSTEM NOTES

- **Counter interaction (B·9):** the horde exploits it deliberately. Throw a Mordor
  Orc at a Shield-Brother first; it eats the Counter and dies; the Uruk Berserker
  then hits a figure whose swing is spent. The Templar answer is **Reach** (halberd
  strikes the approach with no Counter suffered) and **Guard** (Shield Wall blunts
  the follow-up). This is the central tactical dialogue of the matchup.
- **Nerve (B·10):** Templars run **low Nerve numbers** (brave — hard to roll 0
  successes) plus Zeal/Rally; Mordor orcs run **high Nerve numbers** (fragile) so a
  slain friend within 3" can cascade a flank. Uruks sit in the middle but are
  `fearless_uruk`. *(Exact Nerve values set to match the engine's implementation —
  see the sim report; the design intent is Templar ≈ bravest, Mordor Orc ≈ most
  fragile.)*
- **Pricing/points:** each unit gets a points cost from the Forge price model so the
  two factions can field equal-points Banners. Values finalized after the balance
  sims; target ≈ 100-pt and 150-pt Banners, ~45–55% mirror win-rate.
- **Ranged asymmetry is intentional:** Templars have 1 ranged profile, Mordor has 2.
  Templars must weather the approach; Mordor must convert its volley before the wall
  closes. If sims show Mordor winning the ranged phase too hard, Arbalest gets a
  second model or the orc_bow drops a die.
```
