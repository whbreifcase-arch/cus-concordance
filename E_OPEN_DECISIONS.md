# CUS — OPEN DECISIONS
### v0.6 · decision register · updated 2026-07-24

> Eight decisions were opened. **Seven are signed** (William, 2026-07-24) and folded
> into A/B/C. **One is partially open:** the Counter/facing half of combat-aftermath
> is signed; the **morale machinery** (Nerve/Shaken/Rout/Rally/Wild) is still open.
> Signed rulings are kept here for the record and mirrored in the cited sections.

## Status board

| ID | Ruling | State |
|---|---|---|
| grade-accumulation | **Model 2 — Discrete** | ✅ SIGNED → A·VI, B·5 |
| persistent-traits | **Option B — passive Definitions; keyword `trait`** | ✅ SIGNED → B·14, C |
| tool-vocabulary | **Melee · Ranged · Hybrid** (vibe-check) | ✅ SIGNED → A·VII, B·1 |
| temperament | **Five words + behaviour table** (delegated → designed) | ✅ SIGNED → A·VII, B·10 |
| force-ontology | **Force IS a formal primitive** (non-numerical) | ✅ SIGNED → A·II, C |
| packet-classification | **Neutral ID + `packet_index` sidecar** (delegated → designed) | ✅ SIGNED → A·V |
| combat-aftermath | **Counter/facing SIGNED · morale OPEN** | 🟡 PARTIAL → B·8–9 signed |
| base-classes | **Small · Medium · Large** (no Monstrous, no Cavalry-class) | ✅ SIGNED → B·1 |

---

## ✅ grade-accumulation — SIGNED: Model 2 (Discrete)
Resolving Grade *N* resolves **only** the Effects written on Grade *N*. No
inheritance of lower Grades' Effects. Authoring rule: each Grade line is a complete
result; repeat an Effect on every line that should have it. *(William: "MODEL 2
Signed 7/24/26.")* → A·VI, B·5–6.

## ✅ persistent-traits — SIGNED: Option B, keyword `trait`
Always-true properties are **Traits: referenced passive Definitions** — defined once,
referenced by `trait_id`, passive (resolve nothing), stateless. `Large` stays a size;
`unstoppable`, `reach`, `flying`, `fearless`, `amphibious`, `mounted` are traits.
*(William: "Option B referenced passive definitions. Keyword definition: trait.")*
→ B·14, C·Trait.

## ✅ tool-vocabulary — SIGNED: Melee · Ranged · Hybrid
Combat's Tool set, read as **vibe-checks** (ordinal classification like Tempo).
*Hybrid* = delivers Force meaningfully both in contact and at range. Old `Utility` is
a Role, not a Tool. *(William: "Melee, Ranged and Hybrid. Vibe Checks.")* → A·VII,
B·1.

## ✅ temperament — SIGNED (William delegated → designed)
Five: `Cowardly · Resolute · Aggressive · Protective · Ravenous`, each a *preferred
application of Force*, with a leaderless (AI-fallback) and break/Rout behaviour
table. *(William: "just do your thing i give u autonomy here. figure it out.")*
→ A·VII (axis + preference), B·10 (behaviour table).

## ✅ force-ontology — SIGNED: Force is a formal primitive
Force is a first-class Kernel primitive alongside Position, State, Resource — but
**non-numerical** (no Force stat; read through the four axes, expressed by writing
State/Position/Resource). *(William: "Primitive.")* → A·II, C·Force.

## ✅ packet-classification — SIGNED (William delegated → designed)
Primary PACKET ID stays neutral; a **separate `packet_index` sidecar** maps each ID
to retrieval dimensions (`verb`, `module`, `tool`, `targets`, `tags`) so tooling can
query without parsing IDs. Definition-layer, stateless, one-owner, additive.
*(William: "You figure out the best way here.")* → A·V.

## 🟡 combat-aftermath — PARTIAL
**SIGNED (Counter & facing).** Attack a figure and it **Counters and turns to face
you — you are now engaged.** A free (unengaged) target **always** gets its swing; the
first attacker on an open figure eats the Counter. The **only** way to deny a Counter
is position: catch a figure **already engaged with another enemy** on the **flank or
rear** it isn't facing (a Flank/Backstab) — *that* is the "stab them on the side"
case, and it works only because the target is committed elsewhere. Reach without
contact = no Counter. *(William, 7/24/26, corrected same day.)* → B·8–9.

**STILL OPEN — morale machinery.** The **Nerve test** and the **Shaken · Rout ·
Rally · Wild thresholds** (when a figure goes Shaken vs. Routs, how Rally clears it,
the Man/Beast/Spirit/Construct branches), the exact engagement **band distance**, and
the Counter **economy** (once/round vs. a `counter_x` trait, does a dying figure still
swing) are unresolved and must be reconciled from contradictory drafts.

> **RULING (morale):** ⬚ *unsigned — awaiting William.*

## ✅ base-classes — SIGNED: Small · Medium · Large
Three size classes read from the footprint. **No Monstrous** (a "monstrous" figure is
a **Large** carrying traits such as `unstoppable`). **No Cavalry as a class** —
mounted is **elongated geometry** on any size, and plows one class larger.
*(William: "Small Medium and Large no monstrous. No cavalry.")* → B·1, B·4.

---

### The one thing left
Only the **morale aftermath** (Nerve → Shaken/Rout/Rally/Wild, plus the engagement
band and Counter economy) remains open. When you're ready, rule on it the same way
and I'll sign it into B·10.
