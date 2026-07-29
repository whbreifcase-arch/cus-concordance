# ONTOLOGY ANALYSIS — What kinds of things does CUS claim exist?

**Method note.** Concept definitions and status tags are SOURCE (master catalog + Wave‑1 rulings). Category *assignment* is STRUCTURAL INFERENCE from each concept's definition/status unless the catalog's own status column already names the kind. I was **forced to extend** the given 13 with one category — **Classifications / Attributes (axes & types)** — because the Four‑axes family and the type‑taxonomies are attributes *of* entities and fit none of the 13 without distortion (see Flagged Resisters). SOUL is never operationalized.

---

## (1) CATEGORIES WITH MEMBER CONCEPTS

### Entities — things that exist as agents, pieces, or board objects
Figure · Square · Circle · Champion · Fireteam · Sergeant · Retinue · Banner · Army · Kingdom/World · Caravan · Formation · Nest · Base (the piece/measuring instrument) · Screen/chaff (bodies) · Spawn pool (bodies held to re‑enter).
*Note:* Square/Circle are simultaneously **base shapes** (Classification) and the **entity** the shape names — SOURCE lists them as "rank (base shape)."

### State — what is currently true, stored only in the Instance
State (primitive carrier) · Channel of harm · Body · Mind · Wounds · **Morale (Ruling 7: STATE, not Resource)** · Morale track (Steady/Shaken/Broken) · Knocked Out · Dead · Stun · Suppress (1 Morale) · Injury · Scar · hollow · Composure · Yielded · Moved · Neglected/Recovery counter · Activation flag/stoplight · `reloading` · Pin *(struck — folded into Stun+Morale)*.

### Relations — how entities stand toward one another
Position (substrate primitive — "where an entity stands relative to…") · Engagement · Facing/front arc · Reach · Bond · Grudge · Vow · **Standing (Ruling 8: an unquantified Position fact, no meter)** · Hierarchy/Home ground (social Position) · Earshot · Presence/Word/`in_presence`.

### Events — a change that occurs at a moment
Effect (the state‑change a resolved Grade produces) · Impact · Counter · Retort · Rout · Wild · Misfire/Overheat (BLOW‑UP/VENT) · Scatter · Recycle (slain body re‑enters) · Interruption (charge committed).

### Procedures — owned methods that resolve grammar into outcome
MOVE‑resolution · ACTION‑resolution · WAIT‑arming · Save · Armour · **Nerve (Ruling 1: a tiered SAVE)** · Success · Success Grade · Model 2 (Discrete) · Rally (Ruling 9: leader *and* Sergeant may) · Form Up · Reform · Disengage · Alternation/the round · Decision loop (OBSERVE→…→PERSISTENCE) · Harm lifecycle (Wound→Injury→Scar) · Care check/Nerve check (aftermath) · TEND · Reload/card‑down · Overcharge · Continuous Clash Resolution · Ask · Resistance · Scene · Horde engine · Survival/recycle dial · The campaign loop · Persistence I/O (BATTLE RESULT/Sealed Resolver) · Remedy ladder · Sim policy/CI · Procedure (layer).

### Resources — a limited quantity that can be spent (by replenishment kind)
Resource (primitive carrier) · Resource kind (renewing🟢/finite🟡/accumulating🔴) · **Agency/AP (Ruling 2: Square 2, Circle 3)** · **Charge (Ruling 4: names ONLY the finite Resource)** · Strain · The clock/Time · Information · Care capacity · Reaction pool *(SUPERSEDED — struck 2026‑07‑27)*.

### Capabilities — what an agent can do; the executable objects it wields
Force (capacity to produce/resist/alter change — non‑numerical primitive) · MOVE · ACTION · WAIT · Sprint · Overwatch · Brace · PACKET · Fists · Ranged PACKET (gun) · Blackpowder · Shove · Cleave · **Spray (Ruling 3: full roll per hop, 1 Charge; no falloff)** · Blast · ignore Armour · Shield/Shield Intercept · Answer For · Address · Prepare · Mob · Invocation (the five ways a PACKET reaches the resolver) · Written Trigger · OWNED_PROCEDURE.

### Constraints — named legality/limit fields (Law 15: an exception is a field)
`provokes` · `not_in_contact` · `los` · `path` · range · cost · accuracy · Constraints (targeting) as a class · unpierceable · Once per occurrence · 3″ threshold · Line‑of‑sight/cover · Formality dial/Escalation · Architectural Laws 1–15 · Exception‑is‑a‑named‑field · Trait · `size_class` · Monstrous · Mounted (Elongated) · Tier/Class (reserved naming).

### Histories — what survives and accumulates between events
**Persistence (Ruling 5: KERNEL ARCHITECTURE, not a module)** · Attrition (scars/entropy/retirement) · Advancement/Ruin · Period · Instance (layer — the sole home of runtime state) · The Digest (case‑law register) · Verdict (DEGENERATE/TECH) · Decision Register (Doc E) · WHY‑NOT/rationale register (Doc G) · Migration Map (Doc D) · G‑slug · SIGNED/PROVISIONAL/OPEN markers.

### Institutions — governing bodies, doctrines, and standing organizations
Mission · Doctrine · Sub‑faction · Four factions (+signatures) · DM seat/F_AI_DIRECTOR/Charter laws · Scenario generator (SCENARIO_PROMPT) · Intel & leverage (scenario dials) · Four pillars/jurisprudence · Kernel/CUS (the constitutional grammar itself).
*(Army/Kingdom/World also carry an institutional reading; listed under Entities as hierarchy pieces per SOURCE.)*

### Presentation — what the player sees; translates, never forks
Presentation (layer) · Free talk · skins (Ammo/Heat/Mana labels) · Component Layer/Component Law · Three homes · poka‑yoke · Card/reference sheet · Hand/status display · The base is the instrument · Companion application/app · Archetype (readable label) · signature.

### Emergent phenomena — arise from primitives, defined nowhere
**Charge/"surge" (Ruling 4: an emergent qualified Sprint, NOT a defined term)** · Screen/chaff tactic · Faucet‑not‑bucket · Mirror/asymmetry/counter‑web · shield walls (emergent formations) · Mob adjacency effect.

### Reserved unknowns — declared blank on purpose
**SOUL (PROTECTED — permanently blank, non‑numerical, non‑reducible; never defined/valued/triggered)** · Redemption (absent‑by‑design) · Tier/Class (reserved words) · Reserved F_AI_DIRECTOR slot (now filled by Doc L) · Substrate/Carrier (meta primitive‑classes, deliberately abstract).

### [FORCED EXTENSION] Classifications / Attributes — axes & type‑taxonomies carried by entities
Four axes · Role (Pressure/Anchor/Utility) · Tempo · Tool (Melee/Ranged/Hybrid) · Temperament (Cowardly/Resolute/Aggressive/Protective/Ravenous) · RANK (Circle/Square) · CONTROL (played/run) · Creature Type (Man/Beast/Spirit/Construct) · fearless · Hybrid · Formal grammar (Statement/Resolver) · Target · Area · Invocation‑set · Definition (layer) · packet_index (sidecar).
*Rationale:* SOURCE tags these "classification / axis / grammar field." They describe *how an entity relates to Force* or *what a piece is*, not an ability, state, or constraint — a distinct kind the given 13 do not name.

---

## (2) LOW‑RESOLUTION ONTOLOGY STATEMENT (combat‑neutral)

> An **Entity** (Figure, or a nested formation of Figures) occupies a **Position** and carries **State** across three independent **Channels** (Body, Mind, and the reserved third). Each Entity is described — never scored — by its **Attributes**: its Role, Tempo, Tool, and Temperament relationships to **Force**, plus its type and rank.
>
> To act on its own activation, an Entity spends a renewing **Resource** (Agency) to invoke a **Capability**. The player wields three verbs (MOVE, ACTION, WAIT); the engine recognizes five **Invocations** by which a **Capability** — a stateless, neutral **PACKET** — reaches a resolver. Some Capabilities also draw on a finite **Resource** (Charge) or an accumulating one (Strain). A Capability's reach is bounded by named **Constraints** (line‑of‑sight, contact, once‑per‑occurrence).
>
> A **Procedure** resolves the invoked PACKET: dice are counted to a **Success Grade**, a **Save** may resist, and the Grade writes an **Effect** — the **Event** in which State (or Position) actually changes. Out‑of‑turn, a **Written Trigger** fires a Capability free when its condition occurs, gated only by Position, authorship, and death.
>
> Some Events are **Emergent**: they are named nowhere, arising when primitives coincide (a qualified run becomes a charge; cheap bodies become a screen). Between Events, **History** (Persistence, kernel architecture) inherits the outcome — a Wound becomes an Injury becomes a Scar; the record accrues to the Entity's **Instance**, and a jurisprudence register learns from repeated contact. **Institutions** (Missions, doctrines, factions, the governing Laws) frame which intents an Entity may form. Above all of it sits a **Presentation** layer that only re‑labels what the kernel already computes — and one **Reserved** primitive (SOUL) that is witnessed but never read.

---

## (3) CONCEPTS THAT RESIST A SINGLE CATEGORY (flagged, not silently resolved)

- **SOUL** — Reserved unknown by signed tripwire; simultaneously a Channel of harm and a primitive, yet permanently blank. Belongs to *Reserved* only because every other category would require a definition. (PROTECTED.)
- **Position** and **Force** — the two blank substrate/capacity primitives. Position reads as *Relations* but is also the substrate MOVE writes and the cap on out‑of‑turn response; Force reads as *Capability* but is a non‑numerical primitive with no stat. Both straddle Relations/Capabilities/Reserved. (SOURCE: A cross‑links them as "the two blank primitives.")
- **Standing** — *Relations* here, but SOURCE records it as a *dropped Resource* remnant now demoted to a Position fact (Ruling 8). Resists State vs Relation.
- **Morale** — placed in *State* per Ruling 7, but C's raw inventory still lists it as a *Resource* (overridden, flagged).
- **Charge (movement) / "surge"** — *Emergent*, but the word collides with the *Resource* named Charge (Ruling 4 splits them; C‑LAW‑C02 collision left open).
- **Trait** — a Definition that "resolves nothing and holds no runtime state." Sits between *Constraint* (passive legality), *Presentation* (a label), and *Classification*. Placed in Constraints as the least‑bad fit.
- **Impact** — tagged OWNED_PROCEDURE (a *Procedure*) yet is experienced as the contact *Event* a MOVE creates. Straddles Procedure/Event.
- **Bond / Grudge / Vow** — *Relations* by content, but Grudge is a Written Trigger and Vow is a WAIT (*Capabilities/Events*). One concept, two ontic roles.
- **Instance (layer)** — placed in *Histories* as "the only home of runtime state," but it is equally the container of all live *State*. Architecture straddling State/History.
- **Effect** — *Event* (the change) yet defined‑on the PACKET and applied‑by the Procedure; a data field and an occurrence at once.
- **Nerve** — *Procedure* (a tiered Save, Ruling 1), but the aftermath "Nerve/Care check" is still written as a 3‑dice count‑successes roll (E‑LAW‑136) — a **live contradiction the rulings do not reconcile**; do not read the aftermath usage as the save.
- **The Four axes (Role/Tempo/Tool/Temperament), RANK, CONTROL, Creature Type** — the reason for the forced extension: attribute‑taxonomies that are neither Capabilities, States, nor Constraints.
- **Utility** — SOURCE flags it as disputed: named both a Role value and a former Tool value (C/D CONTRADICTION); ruled a Role. Categorized as Classification, dispute noted.
- **Kernel/CUS, Substrate, Carrier, Architectural Laws** — meta‑framework straddling *Institution* (governing constitution) and *Constraint* (the Laws). Split across those two; the Laws sit in Constraints, the grammar‑as‑governance in Institutions.

**Contradictions the binding rulings do NOT cover (carried, not resolved):** aftermath 3‑dice Nerve/Care check vs Nerve‑as‑save (E‑LAW‑136); Push/Shove and Charge‑term name collisions (C‑LAW‑C01/C02); Moved‑eligibility of an NPC Circle — Rank axis vs Control axis (I‑LAW‑070); K‑LAW‑047 "a shot never draws a Counter" vs Overwatch reaction; Doc M "invents no rule" vs its stat blocks.
