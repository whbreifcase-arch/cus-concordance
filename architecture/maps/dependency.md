DEPENDENCY-GRAPH ANALYSIS — CUS Kernel (178 concepts, Wave-1 canon + 10 binding rulings)

Direction convention: `A --rel--> B` means B must exist before A (A depends on / reads / is-built-from B). Build order is the reverse topological sort. Labels: [S]=SOURCE (cited concept/ruling), [SI]=STRUCTURAL INFERENCE, [P]=PROPOSAL.

=====================================================================
(1) EDGE LIST — most load-bearing edges only
=====================================================================

ONTOLOGY / IRREDUCIBLE PRIMITIVES
- Substrate --contains--> Position; Substrate --contains--> Force  [S: A "substrate = Position and Force"]
- Carrier --contains--> State; Carrier --contains--> Resource  [S: A]
- SOUL --(isolated)-->  ∅  [PROTECTED: RESERVED, non-reducible; reads/writes/triggers nothing; witnessed where Body & Mind interact but no edge is operational — do NOT operationalize]
- Instance(layer) --persists--> State  [S: Law 5, "only home of runtime state"]
- Definition(layer) --constrains--> (holds no state)  [S: Law 5]

NAMED RESOURCES & STATE PRIMITIVES
- Agency(AP) --instantiates--> Resource(renewing)  [S]
- Charge --instantiates--> Resource(finite)  [Ruling 4: "Charge" = the Resource only]
- Strain --instantiates--> Resource(accumulating)
- Wounds --is-a--> State(number)  [S: "a number, not a track"]
- Morale --is-a--> State  [Ruling 7: NOT a Resource]; Morale --writes--> Morale track; Morale --resisted-by--> Nerve  [Ruling 1]
- Save --is-a--> resolution primitive; Nerve --is-a--> Save  [Ruling 1: 3-dice test DEAD]; Armour --is-a--> Save
- Channel of harm --contains--> Body, Mind, (Soul-reserved); Body --reads--> Armour; Mind --reads--> Nerve  [S: A·II]
- Creature Type --constrains--> Morale-eligibility & KO-vs-Dead  [S: B·13]

GRAMMAR / EXECUTABLE OBJECT
- PACKET --requires--> State, Effect; PACKET --owned-by--> module  [S: A·V]
- provokes / not_in_contact / los / path / range / cost --constrains--> PACKET legality  [S; Law 15 exception-is-a-field]
- Invocation --contains--> MOVE, ACTION, WAIT, Written Trigger, OWNED_PROCEDURE  [S: A·XIV, five invocations]
- Grade --derives-from--> Success  [S: A·VI, Model-2 Discrete]; Effect --emerges-from--> Grade; Effect --writes--> State | Position
- Statement --contains--> Target, Area, Constraints, Effect  [S: A·XIV]

VERBS / RESOLUTION
- MOVE --requires--> Agency; MOVE --writes--> Position  [S]
- ACTION --requires--> Agency; ACTION --instantiates--> PACKET; ACTION --produces (via Grade)--> Effect  [S]
- WAIT --requires--> Agency; WAIT --arms--> PACKET (against Trigger)  [S: "arming is permission"]
- Overwatch --is-a--> WAIT; Brace --is-a--> WAIT; Brace --requires--> Facing  [S: Circles cannot Brace]
- Counter --is-a--> Written Trigger; Counter --requires--> Engagement, Facing; Fists --carries--> Counter  [S: B·9]
- Impact --emerges-from--> Sprint/MOVE; Impact --contains--> the Push; Impact --may-invoke--> PACKET  [S: OWNED_PROCEDURE]
- the Push --writes--> Position (only)  [S]
- Spray --requires--> Charge (full roll per hop, 1 Charge)  [Ruling 3: −1-die falloff removed]; Cleave --caps-on--> Position
- Blast --constrained-by--> los, path, bands, accuracy; Scatter --emerges-from--> Blast  [S: K·5]
- Stun --rides--> Activation flag  [S: retired "Pin"]

GEOMETRY & ENTITIES
- size_class / Engagement / Facing / Reach --reads--> Base footprint  [S: J "base is the instrument"]
- Figure --owns--> Role, Tempo, Tool, Temperament, signature, PACKET-refs  [S: A·X]
- Square --is-a--> rank; Square --has--> Facing; Square = 2 AP  [Ruling 2]
- Circle --is-a--> rank (faceless); Circle = 3 AP  [Ruling 2]; Circle-break --tracked-on--> separate meter  [Ruling 10, NOT the Nerve save]
- Archetype --derives-from--> Role + Tool + signature  [S]
- Fireteam --contains--> Sergeant, Retinue; Banner --contains--> Champion, Fireteams; Champion --is-a--> Circle
- Champion-wounds --persists-into--> physical tokens (card STATELESS)  [Ruling 6]
- Army --contains--> Banners; Caravan --is--> persistence entity  [Ruling 5/8]

PROCEDURE / BEHAVIOUR
- Rally --is-a--> ACTION (leader OR Sergeant); Rally --writes-up--> Morale track  [Ruling 9]
- Rout --emerges-from--> Broken; Rout --reads--> Temperament  [S]
- Form Up --requires--> Agency (1 AP/figure); --owned-by--> Sergeant  [S]
- Alternation/round --resets--> Agency  [S: B·12]
- Mission --constrains--> Banner behaviour; Mission --overrides--> Doctrine  [S: Law 9, AI-only]

PERSISTENCE (KERNEL ARCHITECTURE, not a module — Ruling 5)
- harm lifecycle: Wound --becomes--> Injury --becomes--> Scar | Recovery  [S: H·7]
- Injury / Scar --persists-into--> Figure Instance  [Ruling 5/8: progression lives in Figure Instance]
- hollow --empties--> Bond (one-way); Bond --heals--> Mind  [S: H·7.7b]
- TEND --reads--> Period; Standing --is-a--> Position fact  [Ruling 8: no meter]

META / CAMPAIGN
- Ask --is-a--> Story resolution unit; Composure --is-a--> State(number)  [S: I·5]
- Address --renames--> ACTION; Prepare --renames--> WAIT; Retort --mirrors--> Counter; Answer For --mirrors--> Shield  [S: Doc I]
- Vow --is-a--> WAIT/Bond; Grudge --is-a--> Written Trigger  [S: "identical to a MIND scar"]
- campaign loop --instantiates--> Decision loop (at scale)  [S: Law 4 recursion]
- Horde engine --owns--> Procedures (no primitive); the clock --is-a--> Resource(Time); Spawn pool --is-a--> Resource
- Scenario generator --consumes--> Story outcomes; Digest --records--> case-law (Verdict, Remedy ladder)

=====================================================================
(2) BUILD ORDER — smallest dependency tiers (rebuild sequence)
=====================================================================

TIER 0  Irreducible substrates/carriers: Position, Force, State, Resource.  [+ SOUL as a parallel isolated RESERVED node — buildable at T0 because it depends on nothing, but it is never referenced by any later tier]
TIER 1  Meta-classes & architecture: Substrate, Carrier, the four Layers (Definition/Procedure/Instance/Presentation), Architectural Laws 1–15, Exception-is-a-field, Four axes (Role/Tempo/Tool/Temperament), Resource-kind classification.
TIER 2  Named resources + state primitives: Agency(AP), Charge, Strain; Wounds, Morale, Morale track; Save → Nerve, Armour; Channel of harm (Body/Mind/Soul-reserved); Creature Type.
TIER 3  Executable grammar: PACKET, packet fields (provokes/not_in_contact/los/path/range/cost), packet_index; Success → Grade → Effect; Target/Area/Statement; Invocation set (incl. Written Trigger, OWNED_PROCEDURE).
TIER 4  Verbs & resolution outputs: MOVE, ACTION, WAIT; Overwatch, Brace; Counter, Fists; Impact/the Push, Shove, Stun, Cleave, Spray, Blast, Scatter, Shot ladder, Save-tiers.
TIER 5  Geometry & entities: Base → size_class/Engagement/Facing/Reach; Figure → Square/Circle; Archetype; Fireteam/Sergeant/Retinue/Banner/Champion/Army/Caravan; Formation.
TIER 6  Procedures & behaviour: Rally, Rout, Wild, Form Up, Reform, Alternation, Doctrine, Mission, Temperament-driven behaviour.
TIER 7  Persistence (kernel architecture): harm lifecycle, Injury, Scar, hollow, Bond, TEND/Care, Period, Standing, Advancement/Ruin, Persistence I/O.
TIER 8  Meta/campaign layers: Story module (Ask/Scene/Composure/Address/Prepare/Retort/Answer For/Vow/Grudge), Horde engine (Nest/Recycle/Spawn pool/clock), Scenario generator, Component Layer, Digest/Verdict/Remedy ladder, campaign loop.

=====================================================================
(3) CYCLES / DESIGN SMELLS
=====================================================================

The architecture is deliberately DAG-shaped (Laws 1/3/7/13 push all reciprocity onto the Tier-0 sources Position & State, which are read-only primitives). Most apparent loops are resolution-time READS, not build-time REQUIRES, and break cleanly at the primitive. Findings:

CYC-1 (not a true cycle — flagged CONTRADICTION rulings do NOT cover): Morale ↔ Nerve. Nerve-as-Save is defined per incoming Morale point [Ruling 1], while Morale resolves through Nerve — a tight coupling that still breaks (Save is a Tier-2 primitive independent of any Morale instance). BUT the aftermath 3-dice "Nerve check" (H·7.3 / E-LAW-136) is a *second, incompatible* Nerve that the rulings explicitly leave open. [SI] This is a latent cycle only because two different objects share the name "Nerve"; I am not resolving it.

CYC-2 (near-cycle, resolvable): Fists ↔ Counter ↔ provokes. Fists carries the Counter trigger; Counter is itself a returned melee PACKET (Fists); `provokes` authorises it. [SI] Broken by building PACKET + provokes + Written Trigger (T3) before Fists (T4) before Counter (invocation, T4). No blocking loop.

CYC-3 (near-cycle, resolvable): Engagement ↔ melee ACTION. Only a melee ACTION creates Engagement, yet packet legality (`provokes:true`) reads Engagement. [SI] Breaks at Position: Engagement is a *derived Position relation* (T5) read off the Base, not a peer of ACTION.

CYC-4 (intended self-recursion, not a smell): Decision loop → campaign loop → Decision loop. Explicitly recursive by Law 4 ("the same loop at every scale"). [S] Self-loop by design.

CYC-5 (name-collision smells the rulings do NOT cover): Push/Shove (C-LAW-C01) and Charge-Resource vs Charge-movement (C-LAW-C02); Moved-eligibility of an NPC Circle (Rank vs Control, I-LAW-070); K-LAW-047 "a shot never draws a Counter" vs Overwatch. [S] These are terminological/semantic collisions, not graph cycles — flagged, not resolved.

Net: no hard build-blocking cycle. The genuine smells are (a) the dual-Nerve naming (CYC-1) and (b) the unresolved collisions in CYC-5.

=====================================================================
(4) DOES THE PROPOSED SHAPE HOLD?  ontology→state→agency→action→resolution→time→conflict
=====================================================================

Mostly correct, but it mis-orders two joints and omits one mandatory tier. [SI, cited]

WRONG JOINT 1 — resolution must precede action. ACTION is defined as "creates Effects via a Grade" [S: ACTION], and Grade = "how well the PACKET succeeded" [S: A·VI]. So Success/Grade/Effect are *prerequisites* of ACTION, not its downstream. The proposed order puts resolution AFTER action — inverted.

MISSING TIER — the PACKET/grammar layer. PACKET is "the single universal executable object… referenced everywhere" [S: A·V] and every verb instantiates or arms one [S: Invocation]. The proposed spine jumps agency→action with no packet layer between them; nothing is executable without it.

SOFT JOINT — "time" is not one clean tier. WAIT is a verb inside the action layer (arming) [S], while trigger *firing*, Alternation, and the clock are genuinely later. Time is split, not sequential.

BETTER ORDER I FOUND (matches the Tier list in §2):
ontology → state+resource-kinds → agency → PACKET/grammar → resolution (Success/Grade/Effect/Save) → action (the three verbs) → time (Written-Trigger firing / Alternation / clock) → conflict (Combat geometry + Story Ask) → persistence → campaign.

Two-line diff from the proposal: (i) insert **PACKET/grammar** between agency and action; (ii) swap so **resolution precedes action**. With those, the proposed shape becomes a valid topological order. SOUL sits outside the spine entirely — an isolated RESERVED node with no operational in- or out-edges, and it stays that way [PROTECTED].
