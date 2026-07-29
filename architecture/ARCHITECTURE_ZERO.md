# ARCHITECTURE ZERO — CUS (low-resolution spine)

Label key: **[S]** SOURCE (catalog/analysis text or a numbered Ruling R#), **[SI]** STRUCTURAL INFERENCE, **[P]** PROPOSAL. SOUL is never operationalized below.

---

## 1. WHAT EXISTS — the kinds of things

The ontology analyst carried 13 categories plus one forced extension; I endorse the extension and collapse to the kinds that carry architectural weight. **[S: Ontology §1; forced extension justified there]**

- **Substrates** — what every read/write touches: **Position** (relational geometry, changed not spent) and **Force** (non-numerical capacity to produce/resist/alter change). **[S: A "substrate = Position and Force"; Force SIGNED 2026-07-24]**
- **Carriers** — how a substrate is stored/spent: **State** ("what is true," saveable/terminal) and **Resource** ("what remains to spend," typed by replenishment). **[S: A·IV; R7]**
- **Reserved primitive** — **SOUL**: formal, permanently blank, non-numerical, non-reducible; witnessed only where Body and Mind interact, never read. **[S: PROTECTED tripwire]**
- **Entities** — agents/pieces/board objects: Figure, and nested formations (Fireteam→Banner→Army→Kingdom/World), plus Caravan, Nest, Base, Spawn pool. **[S: A·X]**
- **Attributes (axes & types)** — how an entity relates to Force or what a piece is: Role/Tempo/Tool/Temperament, RANK, CONTROL, Creature Type — classifications, never scores. **[S: A·VII; "never a fifth axis"]**
- **Capabilities** — the executable objects an agent wields: the **PACKET** (one stateless neutral object) reached by five **Invocations**; the three player verbs MOVE/ACTION/WAIT. **[S: A·V, A·XIV]**
- **Constraints** — named legality fields (an exception is a field, never prose): `provokes`, `not_in_contact`, `los`, `path`, range, cost, `unpierceable`, once-per-occurrence. **[S: Law 15]**
- **Procedures** — owned resolution methods (one per mechanic) turning a Statement into an outcome. **[S: A·IX, Law 14]**
- **Events** — the moment a Grade writes an Effect and State/Position changes; includes emergent ones named nowhere (a qualified Sprint, a screen). **[S: Effect; Ruling 4]**
- **Histories** — what survives between events: Persistence (kernel architecture), the Instance as the sole home of runtime state, the jurisprudence register. **[S: R5; Law 5]**
- **Institutions** — governing frames: Missions, Doctrine, factions, the Architectural Laws, the Kernel grammar itself. **[S: A·XI, A·XV]**
- **Presentation** — what the player sees; re-labels, never forks the mechanic. **[S: A·IX, Law 12]**

---

## 2. WHAT CAN HAPPEN — the core loop

In plain sentences, at one scale and every scale (the loop recurses by Law 4). **[S: Decision loop A·XII; the campaign loop instantiates it]**

An entity **perceives** its Position — where it stands relative to entities, boundaries, threats, and audiences (Position is the only social armour too). **[S: Position]** It **chooses** an intent its Attributes and any Mission permit; Temperament biases the choice when several applications of Force are legal, but modifies no die. **[S: A·VII, A·XI]** On its own activation it **spends Agency** (Square 2 AP, Circle 3 AP), the only pool it spends to act. **[S: R2]** The spend **invokes a Capability** — one of three player verbs arms or resolves a PACKET; the engine also fires PACKETs by Written Trigger and Owned Procedure, free and out-of-turn. **[S: A·XIV]** The **world constrains** the attempt through named fields — line-of-sight, base contact, once-per-occurrence — and through geometry read off the base. **[S: Law 15; J]** An owned **Procedure resolves** it: dice count to a Success Grade, a Save (Armour, Nerve) may resist, and only the reached Grade's own line fires (Model 2, Discrete). **[S: A·VI; R1]** The Grade writes an **Effect**, and **State (or Position) changes** — a Wound, a Shove, a Morale step, a KO. **[S: Effect]** That change is the **Event that enters History**: it accrues to the entity's Instance, and where it survives the battle it enters the harm lifecycle (Wound→Injury→Scar) or a Bond. **[S: R5; H·7]** **Later systems inherit** it: aftermath, campaign, and the jurisprudence register all read what the Event left behind. **[S: A·XII; Digest]**

---

## 3. THE LAYER STACK — the list I endorse

I reconcile the layering analyst's own verdict: their L0–L5/L9/L10 hold; L7, L8, L11, and the missing control plane were category errors. I adopt their four corrections (split Persistence and the Decision loop out as spanners; drop the Figure to primitive altitude; add a governance column; demote L11). **[S: Layering Part 3]** The result is a spine of runtime rungs, two cross-cutting bands alongside it, and one orthogonal column.

**Runtime spine (bottom to top):**

- **L0 Reserved** — holds SOUL and reserved naming (Tier/Class); nothing may ever be authored into it. **[S]**
- **L1 Ontological primitives** — Substrate/Carrier, Position/Force, State/Resource, PACKET, the four axes, RANK/CONTROL/Creature Type, **and the Figure**. Charge: this is the layering analyst's V2 fix — the base-agent must precede the procedures that consume it. **[S: V2]**
- **L2 Runtime state (Instance)** — every live value plus the durable sub-band (Injury/Scar/Bond/Composure-carry) that survives between events. **[S: change 1]**
- **L3 Intent grammar** — the three verbs and the Statement fields; arming, not resolving. **[S: Law 6]**
- **L4 Resolution grammar** — Success/Grade/Effect, Save/Nerve/Armour, the shot ladder. **[S: A·VI; R1]**
- **L5 Owned procedures** — Impact/Push/Shove, Counter, Rally, Spray, Blast, Form Up, Alternation, Ask/Scene. **[S: Law 14]**
- **L6 Conflict modules** — exactly two: Combat and Story; the Horde engine fills the reserved director slot. **[S]**
- **L8 Institutions & campaign** — formations above the Figure, Doctrine/Mission, Scenario generator, campaign loop. (No L7 rung; see spanners.) **[S: change 2]**
- **L9 Presentation** — Component Layer, three homes, the card (stateless), the base as instrument. **[S: R6]**
- **L10 Content & setting** — factions, sub-factions, blackpowder, resource skins. **[S]**

**Cross-cutting bands (not rungs):** **Persistence architecture** (harm-lifecycle contract + Sealed Resolver, adjacent to L1) and the **Decision loop** (spans every scale). Both were mis-filed as strata. **[S: R5; V6]**

**Orthogonal governance column:** Architectural Laws, the Digest, Verdict, Remedy ladder, Decision/rationale/Migration registers, Sim-policy. The Remedy ladder proves this must be orthogonal — its four rungs each act on a different layer. **[S: V3]**

Dropped from the candidate stack: **L7** (its state → L2, its contract → the Persistence band) and **L11** (owns no concept outright; its only anchor is SOUL, which stays inert at L0). **[S: V1, V4]**

---

## 4. BUILD ORDER — dependency order and vertical slice 1

Rebuild in reverse-topological order. This matches the dependency analyst's tiers with the layering analyst's two corrections folded in (PACKET/grammar inserted before the verbs; resolution before action; Figure at primitive altitude). **[S: Dependency §2, §4; Layering V2]**

1. **Primitives** — Position, Force, State, Resource (SOUL exists in parallel, referenced by nothing). **[S: Tier 0]**
2. **Meta-architecture** — the four layers, Laws 1–15, exception-is-a-field, the four axes, resource-kind. **[S: Tier 1]**
3. **Named carriers** — Agency, Charge, Strain; Wounds, Morale, Morale track; Save→Nerve/Armour; Channel of harm; Creature Type. **[S: Tier 2]**
4. **Executable grammar** — PACKET, packet fields, Success→Grade→Effect, Statement, the five invocations. **[S: Tier 3]**
5. **Verbs & outputs** — MOVE/ACTION/WAIT; Overwatch/Brace; Counter/Fists; Impact/Push, Shove, Stun, Cleave/Spray/Blast. **[S: Tier 4]**
6. **Geometry & entities** — Base→size_class/Engagement/Facing/Reach; Figure→Square/Circle; formations. **[S: Tier 5]**
7. **Procedures & behaviour** — Rally, Rout, Form Up, Alternation, Doctrine, Mission. **[S: Tier 6]**
8. **Persistence** (architecture band, drawn on once combat produces outcomes). **[S: Tier 7]**
9. **Campaign/meta** — Story, Horde engine, Scenario generator, Component Layer, Digest. **[S: Tier 8]**

**Vertical slice 1 (minimal playable set) [P, from the same tiers]:** Position + State + Resource; Agency; PACKET + `provokes`/`not_in_contact`; Success→Grade→Effect + Save; MOVE + ACTION + WAIT; Wounds + Armour; the Base with Engagement/Facing; Figure as Square (2 AP) with Fists. This is the smallest closed loop that lets one figure perceive→spend→invoke→resolve→change State — one melee exchange with a Counter. Morale/Nerve, Circle, and all persistence are deferred to slice 2. **[SI: it is the minimal set that closes the §2 loop once]**

---

## 5. WHAT IS INHERITED UPWARD — where emergence becomes possible

Higher layers never re-author lower ones; they inherit through three channels, and emergence lives at the seams. **[S: Laws 3/4/7/12]**

- **Constraints inherit downward-as-read, upward-as-fact.** L5 procedures read geometry off the L1/L2 base ("the base is the instrument"); a screen denying a clean 3″ lane is nowhere defined yet decides a charge. Emergence: *a screen beats a charge*, flanking, the Push plow. **[S: J; V5; Ruling 4 "surge" is emergent]**
- **Qualities inherit as classification, not value.** Role/Tool/signature compose into a readable Archetype; Temperament plus the absence of a Mission composes leaderless behaviour and Rout. Nothing new is added — the combination is the emergent thing. **[S: Archetype; V8]**
- **Histories inherit as accrued state.** A Wound the Instance holds becomes an Injury becomes a Scar; a Moved outcome persists as a Bond; the Digest learns from repeated contact and can promote a TECH exploit to canon. The individual declines while institutions ascend — attrition is the emergent campaign shape, not a mechanic. **[S: H·7; R5; Attrition; Digest]**

The recursion itself is the enabling condition: the same loop at figure scale and campaign scale means an outcome at one altitude is an input at the next. **[S: Law 4; A·XII]**

---

## 6. WHAT CANNOT BE CLOSED — constitutionally

**SOUL is a reserved, permanently-blank, non-numerical, non-reducible primitive. It is never named, called, triggered, read, or state-changed, and this document proposes no definition, value, trigger, or mechanic for it.** It is witnessed only where Body and Mind interact — the structural twin of Force, except Force is read via its axes and SOUL is read never. It sits outside the build spine as an isolated node with no operational in- or out-edges, and it stays that way. **[S: PROTECTED tripwire; Dependency §1; Reduction §3.6]**

By the same constitutional principle, some phenomena are observable and consequential yet reduce to no complete variable, and the corpus keeps them open on purpose: **Redemption** ("the one place where the correct rules text is an absence"), the withheld trigger for **hollow** ("how a figure becomes hollow is deliberately unpublished"), and the emergent charge that is named nowhere. **[S: G/H; Ruling 4]** ARCHITECTURE ZERO records these as declared blanks, not gaps to be filled. Anything the exception-is-a-field test cannot field is, per Law 15, a missing layer — not a prose patch. **[S: Law 15]**

---

## 7. IMPLIED DOCUMENT TREE — cus-second-corpus

The dependency order implies this folder structure — numbered to encode build order, with the two spanners and the governance column pulled out of the numbered spine. **[P, derived from §3–§4; folders map to tiers/layers, not to the legacy Doc A–N split]**

```
cus-second-corpus/
├── 00-architecture-zero.md            # this spine
├── 01-primitives/
│   ├── position.md  force.md          # substrates
│   ├── state.md  resource.md          # carriers
│   ├── SOUL.reserved.md               # blank by law; contains a tripwire, no content
│   └── layers-and-laws.md             # 4 layers, Laws 1–15, exception-is-a-field
├── 02-carriers/
│   ├── agency.md  charge.md  strain.md
│   ├── channels/ body.md  mind.md  save-nerve-armour.md
│   └── wounds.md  morale.md  creature-type.md
├── 03-grammar/
│   ├── packet.md  packet-fields.md  invocations.md
│   └── success-grade-effect.md  statement.md
├── 04-verbs/  move.md  action.md  wait.md  (overwatch, brace, counter, fists)
├── 05-procedures/
│   ├── combat/ impact-push.md  shove.md  spray-blast.md  form-up.md  alternation.md
│   └── story/  ask-scene.md  retort.md  answer-for.md
├── 06-entities/  base.md  figure.md  square-circle.md  formations.md
├── 07-modules/  combat.md  story.md  horde-engine.md
├── 08-institutions/  missions.md  doctrine.md  factions.md  scenario-generator.md  campaign-loop.md
├── 09-presentation/  component-layer.md  three-homes.md  cards.md
├── 10-content/  factions/  skins/  blackpowder.md
├── _spanners/
│   ├── persistence-architecture.md    # harm lifecycle, Sealed Resolver, I/O contract (R5)
│   └── decision-loop.md               # A·XII, recurses at every scale
├── _governance/
│   ├── laws.md  digest/  verdict.md  remedy-ladder.md  sim-policy.md
│   └── registers/ decisions-E.md  rationale-G.md  migration-D.md
└── _open/                             # contradictions the rulings do NOT cover (see §8)
```

Rationale for the non-obvious placements: Persistence and the loop are folders under `_spanners/`, not numbered rungs, because both span every scale (R5, V6); governance is a sibling column because the Remedy ladder acts across layers (V3). **[S: R5; V3, V6]**

---

## 8. TOP OPEN RISKS — ranked

All five analysts independently surfaced the same short list. Ranked by structural blast radius. Each is flagged by the rulings as **not covered** — I respect that and do not resolve them here.

1. **The dual-Nerve name (E-LAW-136).** One word, "Nerve," names two incompatible resolution structures: a tiered Save (R1) and the aftermath 3-dice count-successes check (H/E). This is the highest risk because it plants a *second, live resolution model inside the persistence band* — a latent cycle purely because two objects share a name. **[S: R1 vs E-LAW-136; CYC-1; V(E-LAW-136)]** Named highest by dependency, layering, ownership, and reduction analysts alike.
2. **Contested ownership of the entity hierarchy (V2).** The Figure is depended on by L2–L5 yet the candidate stack filed it at L8, inverting the dependency — a resolution procedure cannot depend on an institution for the agent it resolves. My §3/§4 endorsement of dropping the Figure to L1 *is* the fix; flagged here because any doc that re-files it up re-opens the inversion. **[S: V2; SI]**
3. **No home for the governance column (V3).** Laws, Digest, Verdict, Remedy ladder are cited pervasively yet fit no rung — a stack that omits its own control plane mislocates how every other layer is amended. **[S: V3]**
4. **Push/Shove and Charge-term collisions (C-LAW-C01/C02).** "Push" (charge plow) vs "Shove" (weapon Effect), and "Charge" across Resource / qualified Sprint / retired keyword. Ruling 4 fixed only the Resource name; the Push/Shove split is a same-primitive-two-invocations problem left open. Lower rank: a naming/authoring hazard, not a build-blocking cycle. **[S: C-LAW-C01/C02; Reduction Push/Shove flag]**
5. **Layer-violation couplings that are tolerated but unnamed.** STUN (L4/L5 Effect) rides the L9 activation flag; behaviour (L5) tests for Mission (L8) absence; the base is simultaneously L9 component and L1/L2 data source. Each is a deliberate collapse the stack should *name* rather than hide. **[S: V5, V7, V8]**
6. **Rank-vs-Control disagreement on Moved-eligibility (I-LAW-070).** Two L1 axes disagree on whether an NPC Circle can be Moved; a genuine primitive-level conflict, but narrow in reach. **[S: I-LAW-070]**
7. **The under-specified battle→battle boundary.** Wounds, Morale, Charge, and Strain lack explicit at-battle-end reset/replenish rules; Morale (one-way ratchet, no stated cross-battle clear) and unbounded **hollow** decay are the sharpest. Attrition is a stated principle but the per-resource reset semantics are unwritten. **[S: Ownership TIME cross-cutting flags]** Ranked last structurally but is the most likely to bite in play.

Also carried, not ranked: K-LAW-047 ("a shot never draws a Counter" vs Overwatch) and Doc M's "invents no rule" vs its stat blocks (a potential L10→L4 leak). **[S: master-catalog contradiction notes]**

---

*Discipline note: no contradiction above was silently resolved; every binding ruling (R1–R10, SOUL tripwire) was treated as decided canon, and each conflict the rulings leave open is flagged as open. SOUL carries no proposed definition, value, trigger, or mechanic anywhere in this document.*
