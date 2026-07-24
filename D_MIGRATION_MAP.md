# CUS — THE MIGRATION MAP
### v0.6 · every old term → its new owner or replacement · 2026-07-23

> How the old vocabulary maps onto the rebuilt Kernel. **Nothing valuable is
> silently deleted** — where a retired term keeps useful flavour or archetype
> value, the "New treatment" column says so. Terms marked ⚠ point to an open
> ruling in [Document E](E_OPEN_DECISIONS.md).

---

## 1 · Verbs & actions

| Old | New treatment |
|---|---|
| MOVE / ATTACK / USE / READY | **MOVE / ACTION / WAIT** |
| ATTACK (primitive) | **ACTION** resolving a PACKET |
| USE (primitive) | **ACTION** resolving a PACKET |
| READY (primitive) | **WAIT** arming a PACKET |
| Charge = MOVE + ATTACK | **Sprint** (movement) creates **Impact**; Impact resolves the relevant PACKET |
| Charge (rules keyword) | **Retired.** "Charge" survives as ordinary flavour only |

## 2 · PACKETs

| Old | New treatment |
|---|---|
| Attack Packet | **PACKET** |
| Ability Packet | **PACKET** |
| Weapon Packet | **PACKET** |
| Reactive Packet | **PACKET** (armed by WAIT) |
| Passive Packet | **Not a PACKET.** A persistent trait — home ⚠ E·persistent-traits |
| Typed IDs `ATK_07 · ABIL_04 · REACT_02 · PASSIVE_09` | **Neutral IDs** (`spear_thrust`); classification deferred to separate JSON ⚠ E·packet-classification |
| Harmful / beneficial tag | **Do not add.** Target + context decide |
| "The Tiers are the weapon" | The PACKET's **Grades and Effects** define its resolution |

## 3 · Result structure

| Old | New treatment |
|---|---|
| Ladder | **Success Grade / Grade** |
| Tiers (as packet result) | **Grade** |
| Rungs / Outcome Track | **Grade** |
| Tier / Class | **Reserved** for persistent size / organizational classification — *not* the packet result |
| "best Wound + every passed Effect" | ⚠ **E·grade-accumulation** — inherit-lower vs. own-Effects-only is unresolved |

## 4 · Roles

| Old | New treatment |
|---|---|
| Five universal Roles | **Three: Pressure / Anchor / Utility** |
| Assault | **Pressure** (or a player-facing archetype) |
| Skirmisher | **Pressure/Utility** + Tempo/Tool/Temperament, or an archetype |
| Control | **Utility** (or an Effect / tag / archetype) |
| Support | **Utility** (or an archetype) |
| Anchor (old) | **Anchor** (kept, redefined: *prevents Force*) |
| Reach (as a Role) | **Removed as a Role.** A PACKET property or trait ⚠ E·persistent-traits |
| Projection | **Removed as a Role.** Express via Role + Tempo + Tool + PACKETs |
| Heavy / Light cavalry Role split | **Removed.** Express through Role · Tempo · Tool · PACKETs · geometry |

## 5 · The four axes (new / reframed)

| Old | New treatment |
|---|---|
| (no explicit Tempo) | **TEMPO** — new axis, ordinal `> / >> / >>>` (Slow/Normal/Fast) |
| Role + old Tool = Class | **Rebuilt:** `Role + Tool + signature = Archetype` |
| Tool = `Melee / Ranged / Utility` | **Not preserved automatically.** Utility is now a Role; melee/ranged may be PACKET properties. Tool vocabulary is ⚠ E·tool-vocabulary |
| Temperament (as AI script) | **TEMPERAMENT** — reframed as *preferred application of Force*; list/consequences ⚠ E·temperament-vocabulary |

## 6 · Identity

| Old | New treatment |
|---|---|
| Creature Type `Man/Beast/Spirit/Construct` | **Kept** — *what an entity is* (Combat's set) |
| Archetype `(Role+Tool)×signature` | **Rebuilt** as `Role + Tool + signature → Archetype`; readable, not a primitive |
| "Skirmisher / Tank / Sniper" as Roles | **Archetypes / player-facing descriptions**, not Roles |

## 7 · Architecture (preserved, wording updated)

| Old | New treatment |
|---|---|
| DEFINITION → PROCEDURE → INSTANCE → PRESENTATION | **Preserved unchanged** |
| The 14 Architectural Laws | **Preserved and updated** (A · XV) — Law 10 now explicitly covers *classification vs. statistic* (Tempo) |
| Recursive hierarchy Figure→…→Kingdom | **Preserved** (A · X) |
| Caravan as physical persistence | **Preserved** (A · X) |
| Missions are AI-only | **Preserved** (Law 9, A · XI) |
| Translation layer / formal grammar | **Preserved**, retargeted to three verbs |

## 8 · Combat facts (kept in Module B, retunable)

| Old | New treatment |
|---|---|
| Bases: shape=type, size=class, elongated=mounted | **Kept** (B · 1); millimetres ⚠ E·base-millimetres |
| Push / Indent / Crush geometry | **Kept** (B · 4), now driven by Sprint→Impact |
| Wounds `Fine→Hurt→KO→Dead` | **Kept** (B · 7), Combat fact |
| Armour `None/Light/Medium/Heavy = —/6+/5+/4+` | **Kept** (B · 7), Combat fact — **not** a Kernel primitive |
| Alternation | **Kept** (B · 12), "attention management" |
| Formations descriptive | **Kept** (B · 11) |
| Counter · Nerve · Shaken · Rout · Squelch · Wild · Rally | **Held for reconciliation** ⚠ E·combat-aftermath — not copied from archived drafts |
| Persistent traits (Large/Flying/Fearless/Reach/Amphibious) | **Held** ⚠ E·persistent-traits |

## 9 · Downstream artifacts (built on the old vocabulary — need migration)

These already exist and use v0.5 words. They are **not** authority; they are
migration debt to reconcile against A–C when the open rulings land.

| Artifact | Uses (old) | Migration when signed |
|---|---|---|
| `CUS_TTS_MOD/` (TTS playtest) | four verbs, five Roles, typed packet IDs (`ATK_*`), "Tiers" | remap radial wheel to MOVE·ACTION·WAIT; Roles→P/A/U; packet IDs→neutral; "Tiers"→"Grade"; Charge→Sprint/Impact |
| `unit_library.json` (73 units) | `role`, `attack_packet_ids: ["ATK_*"]`, `tiers` string | rewrite roles to Pressure/Anchor/Utility (+archetype), neutral packet IDs, `grades` |
| `card_forge_v3.html` bindings | `{role}`, `{tiers}`, `{tool}` | rename bindings once Tool vocabulary + Grade display are signed |
| `CUS_CODEX.md` v0.5 | everything above | becomes a retired **migration input**; not edited in place — superseded by this folder |

> Do not migrate the downstream artifacts until the relevant open rulings in
> **Document E** are signed — several remaps (Roles, Tool vocabulary, Grade
> accumulation, neutral-ID scheme) depend on decisions that don't exist yet.
