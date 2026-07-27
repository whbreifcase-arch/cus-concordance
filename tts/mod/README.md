# CUS — Tabletop Simulator Playtest Interface
### For CUS Codex v0.5 (the single source of truth: `../CUS_CODEX.md`)

A fast, tactile TTS mod framework that removes bookkeeping without replacing
player judgment. The battlefield stays clean; you interact through the
miniature, its linked card, a four-action radial wheel, short resolver panels,
and named hotkeys.

It respects the Codex separation end-to-end:

```
DEFINITION  →  PROCEDURE  →  INSTANCE  →  PRESENTATION
(the card)     (the module)   (the mini)   (wheel/panels/icons)
```

* **Cards own the DEFINITION** — Role, Tool, Creature type, stats, packet
  references. Never runtime state.
* **Miniatures own the INSTANCE** — Wounds, AP, activation flags, conditions,
  facing, formation membership.
* **The Combat Module owns the PROCEDURES** — movement, the signed attack Tiers,
  armour, Counter, formation assistance.
* **The UI is PRESENTATION only** — the radial wheel, floating state icons,
  resolver panels, the card viewer, logs.

The canonical actions are **exactly four**: `MOVE · ATTACK · USE · READY`.
Everything else is an alias or a packet beneath one of them.

---

## Repository layout

```
CUS_TTS_MOD/
  README.md                     ← this file
  src/
    Global.lua                  ← controller (uses #include; bundle for hand-paste)
    Global.xml                  ← all player-local panels + the radial wheel
    core/       Constants · Schema · Logger · EventBus · Undo · Geometry · StateStore
    objects/    CardController · MiniatureController · Fixture
    modules/    PacketRegistry · ArmourResolver · AttackResolver · CounterResolver
                MovementResolver · ChargeAssistant · ConditionManager · NerveResolver
                FormationAssistant · RoundManager
    ui/         RadialWheel · CardViewer · StatePanel · AttackPanel · MovementPanel
                NervePanel · FormationPanel
    data/       sample_packets.(lua|json) · sample_units.(lua|json)
  build/
    bundle.ps1                  ← inlines #include → build/Global.bundled.lua
    Global.bundled.lua          ← generated; paste-ready single file
  docs/
    SETUP.md · HOTKEYS.md · SAVELOAD.md · KNOWN_LIMITATIONS.md
  tests/
    acceptance_checklist.md
```

## Two ways to install

1. **Official TTS Lua extension (Atom / VS Code).** Point it at `src/`, open the
   Global script, and it resolves the `#include` lines. Paste `Global.xml` into
   the Global UI, and the two object scripts onto your card / miniature objects.
2. **Hand-paste (no extension).** Run `build/bundle.ps1` to produce
   `build/Global.bundled.lua`, paste that into the Global **Lua** slot, paste
   `src/Global.xml` into the Global **XML** slot, and paste
   `src/objects/CardController.lua` / `src/objects/MiniatureController.lua` onto
   your card / miniature objects.

Full steps, including the one-click **Spawn Test Fixture** button, are in
[`docs/SETUP.md`](docs/SETUP.md). Hotkey mapping is in
[`docs/HOTKEYS.md`](docs/HOTKEYS.md). What's finished vs. deliberately left as a
manual/plugin hook is in [`docs/KNOWN_LIMITATIONS.md`](docs/KNOWN_LIMITATIONS.md).

## Design guarantees (the non-negotiables)

* No runtime state is ever stored on a definition/card (Law 5).
* The card PNG/SVG is never parsed for data — structured values always exist.
* Nothing mutates a defender until **Apply** is pressed.
* Every modifier in the attack ledger shows its **source** and its consequence.
* Measurable facts (distance, facing, bases touching) are auto-detected;
  **judgments** (LoS, cover, high ground, engagement for Mob Rule) are always
  player-confirmed.
* Routed models are never auto-moved — the exact Temperament instruction is
  shown and the player moves the figure.
* Where the Codex does not define an exact resolver (Nerve dice, Wound-state
  numeric transition), the mod exposes a configurable/manual **hook** instead of
  inventing a rule.
