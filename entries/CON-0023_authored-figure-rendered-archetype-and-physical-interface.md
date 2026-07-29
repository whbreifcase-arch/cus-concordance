# CON-0023 — Authored Figure / rendered Archetype; the physical interface; Book ⁄ Caravan scales

**Disposition:** RESOLVED · ratified 2026-07-29 (William).
**Supersedes the *Archetype layer-status* clause of [CON-0022]** (which framed Archetype as
"compiled/derived"). The **constructor notation of CON-0022 stands**; only Archetype's *status*
changes. CON-0022 is marked *partially superseded* in its own header — its body is preserved as an
honest record of how the architecture evolved.

## 1. The Figure is authored; the Archetype is rendered
- A **Figure is authored** — explicit primitive fields (`role`, `tool`, `signature`, `tempo`), a `chassis`, `temperament`, `default_doctrine`, and **Packet references**. This is the authoritative truth, code all the way down.
- An **Archetype is *rendered*** — a **Presentation view** of that authored truth. There is **no Archetype object, no Archetype layer**, nothing between the Figure and its Packets; the **engine never resolves an "Archetype."**
- The formula `(Role × Tool) ▷ Signature @ Tempo → Archetype` is a **Presentation constructor**, not a solver. **No reverse inference:** Role/Tool/Signature/Tempo/Archetype are **never** inferred from packets, effects, or costs. Validation may check references, capacity, socket legality, and compatibility — nothing more.

## 2. The physical interface is not a new Kernel layer
Physical cards, sleeves, Frames, Books, tokens, and models are **manifestations inside the existing
four layers** (Definition · Procedure · Instance · Presentation) — mostly **Presentation**, plus
**Position** and **containment**. There is **no fifth "physical layer."** Presentation still
translates/mirrors and is never authoritative.

## 3. Both faces of a Packet card are Presentation
- The **authoritative Packet Definition is the JSON in code.**
- **Front** = play-facing Presentation view · **Back** = kernel-facing Presentation view. One physical card is **one two-sided Presentation artifact referencing one Packet Definition.**
- If a printed face disagrees with the JSON, **the JSON wins** (Definitions are the source; Presentation is a mirror).

## 4. FrameSpec vs. physical Frame — and Frame is not a root Object
- **FrameSpec** = the digital authoring schema — socket contract, capacity, required/optional Packet relationships, non-operative tooling data. It **guides legal construction**; it is not stored in the finished Figure.
- **Physical Frame** = printed housing/sleeve, keyed slots, masks, windows — the **material Presentation of the FrameSpec.**
- Same design, two resolutions, **not** duplicate authorities. **Frame is NOT a new root Object kind** beside Entity/Packet/Relationship — it is an authoring construct + interface component.

## 5. Book ⁄ Caravan — a topology correction, not an ownership fix
Slice 3's Caravan was **already correct** on ownership (membership is a Relationship; the Caravan
keeps no roster copy; Figures own their own durable state). The real gap was the **missing personal
scale.** New topology:

```
Book    ──personal-membership──▶  Figure          (each player's personal container)
Caravan ──expedition-membership─▶ Book             (the shared expedition)
Caravan ──(direct)──────────────▶ communal assets  (hirelings, pack animals, NPC escorts — only if genuinely shared)
```
The Caravan queries its travelling Figures **transitively through the Books.**

- **Book** — an **Entity** with its own Definition + Instance, owning **only Book-specific facts**: personal resources, capacity, selections/commitments, Book-specific persistent state. **The Book does not absorb Figure state.**
- **Figure** — still owns its name, Injuries, Scars, Wounds/state, advancement, capabilities.
- **Book–Figure Relationship** — owns personal membership/attachment.
- **Caravan** — owns shared supplies, facilities, capacity, expedition state; relates to participating Books; may relate directly to communal assets.
- **Containment is not ownership.** The physical Book *nook* under the Caravan mirrors the `Caravan → Book` relationship; a Book is sheltered by the Caravan while remaining personally owned.

## The central model
```
CODE / AUTHORITY :  Figure Definition (chassis · role · tool · signature · tempo · temperament ·
                    default_doctrine · packet refs · optional knobs)  +  FrameSpec (guides construction)
                    +  Packet Definitions (executable truth)
PHYSICAL / PRESENTATION :  Caravan (shared state + Book nook) ▸ Book (personal) ▸ physical Frame ▸ two-sided Packet cards
RENDERING :  (Role × Tool) ▷ Signature @ Tempo  →  human-facing Archetype package
```

Slogans (ratified): *The Figure is authored; the Archetype is rendered. The FrameSpec constrains
construction; the physical Frame embodies it. Both faces of a Packet card are Presentation; the JSON
is Definition. The Book carries the personal; the Caravan carries the shared. Containment is not
ownership.*

## Destination
- `composition/` — reworded to authored/rendered + constructor-not-inference + FrameSpec.
- `interface/` — new physical-interface module (governed by the four layers).
- `slice-3/` — add the **Book** Entity + `Book→Figure` / `Caravan→Book` topology, without discarding the existing ownership rules.

## Explicitly unresolved (not invented)
- The exact **FrameSpec sockets** (required/optional per Role×Tool).
- The **physical keyed-geometry** language (edge/notch per Packet category).
- **Signature *compatibility*** rules (which signatures are legal on which frames) — **validation only, never inference.**
- **Doctrine / Overlays / Faction Knobs** full content.
- **Solo vs group** Book boundaries, and whether an NPC warband uses a Book or only a Caravan.
