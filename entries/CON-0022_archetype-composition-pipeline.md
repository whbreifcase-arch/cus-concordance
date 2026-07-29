# CON-0022 — The Archetype composition pipeline

> **⚠ Partially superseded by [CON-0023] (2026-07-29).** The *Archetype layer-status* framing below
> ("compiled / derived") is corrected there to **Figure-authored / Archetype-rendered (a Presentation
> view)** — there is no operative Archetype object. The **constructor notation and the pipeline stages
> (Frame → Signature → Tempo) stand.** This body is preserved as an honest record of how the
> architecture evolved; read it with CON-0023.

**Disposition:** RESOLVED · ratified 2026-07-29 (William). Closes a real seam the frozen First Corpus
left open. Concordance ruling; directs the Second Corpus `composition/` layer.

## The seam
The rebuilt material remembered **four** axes — Role, Tool, Tempo, Temperament — but the frozen
`ARCHETYPES.md` only ever resolved:

```
Frame     = Role × Tool
Archetype = Frame + Signature
```

So **Tempo never actually entered composition** (a named-but-dead axis), while Temperament correctly
stayed independent. The old reference then *smuggled* Tempo into archetype descriptions (e.g. "Piercer
= Shooter + Pierce" with a hidden "slow") — layer leakage with no owner.

## The ruling
An **Archetype is compiled, not authored**, by a pipeline with **distinct operator semantics**:

```
ARCHETYPE = Tempo( Signature( Role × Tool ) )        (Role × Tool) ▷ Signature @ Tempo = Archetype
              ×  locate the functional cell (Frame)
              ▷  resolve that cell into a repeated decision loop (Signature)
              @  express that loop at a cadence (Tempo)
```

1. **Frame = Role × Tool** — a nine-cell space of functional sockets; owns Role, Tool, and packet expectations, **not** body/equipment/personality.
2. **Signature is a resolver, not a coordinate** — it acts on `Role × Tool` *together*. The same Signature resolves differently per Frame (`Suppress` = advance-cover on Pressure×Ranged, lane-denial on Anchor×Ranged, an ally-buff on Utility×Ranged).
3. **Tempo is the cadence of the decision loop** (planning horizon / commitment / counterplay) — **not** movement (that is Position/MOVE), and **read by humans, never the resolver** (Law 10). `Precision @ Fast/Normal/Slow` → Sharpshooter / Marksman / Sniper.
4. **Archetype is DERIVED, not authored.** The primitives (`role, tool, signature, tempo`) are authoritative; the composer computes the human-facing label. Contradictory data (`Utility/Melee/Heal/Fast → "Sniper"`) becomes impossible to write, because `archetype` is output, not a field.

## The unit profile
Archetype is only the *function*. A whole figure stacks six layers, each owning one concern:

```
UNIT PROFILE = CHASSIS + ARCHETYPE + TEMPERAMENT + DOCTRINE + OVERLAYS + FACTION KNOBS
```

Computational reading: Role×Tool = interface · Signature = implementation · Tempo = scheduler ·
Archetype = executable identity · Chassis = hardware · Temperament = fallback psychology · Doctrine =
operating policy · Overlays = decorators · Faction Knobs = configuration.

## Relationship to the First Corpus
This **corrects and supersedes** the frozen archetype reference's *composition* (Tempo now enters the
pipeline; the hidden-Tempo leak is extracted into its own layer). It **preserves** the old model's layer
separation (Chassis / Temperament / Doctrine / Overlays / faction mods stay independent). Author:
William "vibed" the formula; the pipeline semantics are his.

## Information preserved / rejected
- **Preserved:** Frame = Role × Tool; Signature as the distinctive third ingredient; Temperament independent; the layered Chassis/Doctrine/Overlays model.
- **Rejected:** Tempo as a dead axis; Tempo hidden inside archetype descriptions; the flat reading `Role × Tool × Signature × Tempo` (four interchangeable coordinates) — it is a pipeline, not a product.

## Destination
Second Corpus `composition/` — 01_AXES (values), 02_ARCHETYPE (the pipeline), 03_UNIT_PROFILE (the stack).

## Open
- Frame / Archetype **names** are ⚠ PROVISIONAL — reconcile against frozen `ARCHETYPES.md`, tune in play.
- **Doctrine · Overlays · Faction Knobs** are named and bounded but not yet fully specified.
- The **Signature-resolves-per-Frame** behaviour (one Signature, three resolved loops) is a rich mechanic to formalize (how a packet's meaning shifts by Frame).
