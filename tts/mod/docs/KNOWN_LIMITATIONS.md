# Known limitations & deliberate manual/plugin hooks

These are **separated from finished features on purpose.** Several are direct
consequences of the Codex ("don't invent an unsigned resolver") or of TTS's API.

## Deliberate hooks (the Codex does not define an exact resolver)
* **Nerve dice resolver** — the Codex defines Nerve *eligibility* (Circle heroes
  and Spirit/Construct never test; Square Man/Beast may) but **not** a numeric
  dice procedure in v0.5. `NervePanel` therefore explains eligibility and offers
  manual Pass / Fail / Shaken / Rally / Rout plus a `NerveResolver.plugin` hook
  for a future signed resolver. On Rout it shows the exact Temperament
  instruction and never moves the figure.
* **Wound-state transition** — the Codex names `Fine → Hurt → KO → Dead` but
  supplies no numeric table. Current Wounds are tracked numerically; the state
  label mapping is a configurable hook, and manual KO/Dead/set-Wounds are always
  available. Dead/removed requires confirmation and never deletes the model
  automatically.
* **Charge geometry** — the assistant computes measurable facts (straight lane,
  impact candidates, effective size class, Small slip-through, mounted class-up,
  Monstrous body-immunity) and lets the player **confirm** each Shove/Indent/
  Wall-Jam outcome. It never physics-flings models; wall-jam +2 dice applies
  only after the player confirms a true jam.
* **Engagement / Mob Rule / LoS / cover / high ground** — descriptive geometry.
  The mod proposes candidates and requires confirmation; it does not enforce
  engagement through physics.

## TTS API constraints
* **No global object left-click event.** Target selection and linking use
  **hover + hotkey** and **selection + context menu** instead of raw clicks (see
  `HOTKEYS.md`). This also prevents accidental attacks, which the Codex warns
  against.
* **Radial wheel is screen-anchored**, not cursor-anchored — TTS cursor-anchored
  UI placement is unreliable, so the wheel opens at screen centre (as the spec
  allows).
* **Card image** uses the definition's `card_image_url`. If it's empty, the
  viewer falls back to highlighting the physical card. Point `card_image_url` at
  a hosted PNG (e.g. a Card Forge export) for the large in-panel view.
* **Base-touching / edge-to-edge** distances use approximate base radii derived
  from the Codex base sizes; they're good for auto-flagging "bases touching" and
  engagement bands but the player remains the arbiter in ambiguous cases.
* **Facing** needs a one-time *Calibrate Forward Axis* per model shape so the
  arc math matches how the mesh actually faces.

## Fixture caveats
The **Spawn Test Fixture** button attaches *compact* stub scripts to spawned
blocks/tiles (all heavy logic is in Global). For a polished production table,
paste the full `CardController.lua` / `MiniatureController.lua` onto your own
models instead — they add the full context menus and GM-Notes editing surface.

## Not built (out of scope for the Combat playtest)
Roleplaying / Politics / Kingdom / War modules, the Caravan persistence layer,
and the Mission/AI grammar are **designed but not built** in the Codex and are
not implemented here. The framework keeps the four canonical verbs, packet
references, and definition/instance separation so those modules can plug in
later without a rewrite.
